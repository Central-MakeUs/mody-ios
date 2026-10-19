//
//  CoreKeyChainStorageSecurityTests.swift
//  CoreKeyChainStorageTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreKeyChainStorage
import CoreKeyChainStorageInterface
import Foundation
import Security
import XCTest

// These tests exercise the real simulator Keychain with isolated account keys.
final class CoreKeyChainStorageSecurityTests: XCTestCase {
    private let sut = CoreKeyChainStorage()
    private var keys: [String] = []

    override func tearDownWithError() throws {
        for key in keys {
            let status = SecItemDelete(query(key) as CFDictionary)
            XCTAssertTrue(
                status == errSecSuccess || status == errSecItemNotFound,
                "Failed to remove test key: \(status)"
            )
        }
        keys.removeAll()
        try super.tearDownWithError()
    }

    func testSaveAndReadStringsIncludingEmptyAndUnicodeValues() throws {
        for value in ["", "access-token", "한글 +/&?=🔑"] {
            let key = makeKey()

            try sut.save(key: key, value: value)
            let actual: String = try sut.read(key: key)

            XCTAssertEqual(actual, value)
        }
    }

    func testSaveAndReadBooleanValues() throws {
        for value in [true, false] {
            let key = makeKey()

            try sut.save(key: key, value: value)
            let actual: Bool = try sut.read(key: key)

            XCTAssertEqual(actual, value)
        }
    }

    func testSaveAndReadCodablePayload() throws {
        let key = makeKey()
        let expected = StoredPayload(token: "token", isComplete: true, groups: [1, 2, 3])

        try sut.save(key: key, value: expected)
        let actual: StoredPayload = try sut.read(key: key)

        XCTAssertEqual(actual, expected)
    }

    func testDifferentKeysKeepIndependentValues() throws {
        let firstKey = makeKey()
        let secondKey = makeKey()
        try sut.save(key: firstKey, value: "first")
        try sut.save(key: secondKey, value: "second")

        try sut.update(key: firstKey, value: "updated")
        let first: String = try sut.read(key: firstKey)
        let second: String = try sut.read(key: secondKey)

        XCTAssertEqual(first, "updated")
        XCTAssertEqual(second, "second")
    }

    func testDuplicateSaveReplacesExistingValue() throws {
        let key = makeKey()
        try sut.save(key: key, value: "old-token")

        try sut.save(key: key, value: "new-token")
        let actual: String = try sut.read(key: key)

        XCTAssertEqual(actual, "new-token")
    }

    func testDuplicateSaveCanChangeStoredType() throws {
        let key = makeKey()
        try sut.save(key: key, value: "old-value")

        try sut.save(key: key, value: true)
        let actual: Bool = try sut.read(key: key)

        XCTAssertTrue(actual)
    }

    func testUpdateChangesExistingValue() throws {
        let key = makeKey()
        try sut.save(key: key, value: "old-value")

        try sut.update(key: key, value: "updated-value")
        let actual: String = try sut.read(key: key)

        XCTAssertEqual(actual, "updated-value")
    }

    func testUpdateMissingKeyPreservesItemNotFoundStatus() {
        let key = makeKey()

        XCTAssertThrowsError(try sut.update(key: key, value: "value")) { error in
            guard case let KeyChainStorageError.unExpectedStatus(status) = error else {
                XCTFail("Expected unExpectedStatus, got \(error)")
                return
            }
            XCTAssertEqual(status, errSecItemNotFound)
        }
    }

    func testReadMissingKeyThrowsNoMatchKeyError() {
        let key = makeKey()

        XCTAssertThrowsError(try sut.read(key: key) as String) { error in
            guard case KeyChainStorageError.noMatchKeyError = error else {
                XCTFail("Expected noMatchKeyError, got \(error)")
                return
            }
        }
    }

    func testReadWithWrongTypeThrowsDecodingFailedAndKeepsStoredValue() throws {
        let key = makeKey()
        try sut.save(key: key, value: "stored-token")

        XCTAssertThrowsError(try sut.read(key: key) as Bool) { error in
            guard case KeyChainStorageError.decodingFailed = error else {
                XCTFail("Expected decodingFailed, got \(error)")
                return
            }
        }
        let actual: String = try sut.read(key: key)
        XCTAssertEqual(actual, "stored-token")
    }

    func testReadMalformedJSONThrowsDecodingFailed() throws {
        let key = makeKey()
        var item = query(key)
        item[kSecValueData as String] = Data("not-json".utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            XCTFail("Could not seed malformed JSON: \(status)")
            return
        }

        XCTAssertThrowsError(try sut.read(key: key) as String) { error in
            guard case KeyChainStorageError.decodingFailed = error else {
                XCTFail("Expected decodingFailed, got \(error)")
                return
            }
        }
    }

    func testSaveStoresJSONAndDeviceOnlyUnlockedAccessibility() throws {
        let key = makeKey()
        try sut.save(key: key, value: "token")

        var itemQuery = query(key)
        itemQuery[kSecReturnAttributes as String] = true
        itemQuery[kSecReturnData as String] = true
        var result: CFTypeRef?
        let status = SecItemCopyMatching(itemQuery as CFDictionary, &result)

        XCTAssertEqual(status, errSecSuccess)
        let attributes = try XCTUnwrap(result as? [String: Any])
        XCTAssertEqual(
            attributes[kSecAttrAccessible as String] as? String,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        )
        let data = try XCTUnwrap(attributes[kSecValueData as String] as? Data)
        XCTAssertEqual(try JSONDecoder().decode(String.self, from: data), "token")
    }

    func testDeleteRemovesOnlyRequestedKey() throws {
        let removedKey = makeKey()
        let retainedKey = makeKey()
        try sut.save(key: removedKey, value: "removed")
        try sut.save(key: retainedKey, value: "retained")

        try sut.delete(key: removedKey)

        XCTAssertThrowsError(try sut.read(key: removedKey) as String) { error in
            guard case KeyChainStorageError.noMatchKeyError = error else {
                XCTFail("Expected noMatchKeyError, got \(error)")
                return
            }
        }
        let retained: String = try sut.read(key: retainedKey)
        XCTAssertEqual(retained, "retained")
    }

    func testDeleteMissingKeyIsIdempotent() throws {
        let key = makeKey()

        try sut.delete(key: key)
        try sut.delete(key: key)
    }

    func testDeleteExistingKeyIsIdempotent() throws {
        let key = makeKey()
        try sut.save(key: key, value: "value")

        try sut.delete(key: key)
        try sut.delete(key: key)
    }

    func testDeletedKeyCanBeSavedAgain() throws {
        let key = makeKey()
        try sut.save(key: key, value: "before")
        try sut.delete(key: key)

        try sut.save(key: key, value: "after")
        let actual: String = try sut.read(key: key)

        XCTAssertEqual(actual, "after")
    }

    func testFailedSaveEncodingLeavesExistingValueUnchanged() throws {
        let key = makeKey()
        try sut.save(key: key, value: "original")

        XCTAssertThrowsError(try sut.save(key: key, value: Double.nan)) { error in
            guard case KeyChainStorageError.encodingFailed = error else {
                XCTFail("Expected encodingFailed, got \(error)")
                return
            }
        }
        let actual: String = try sut.read(key: key)
        XCTAssertEqual(actual, "original")
    }

    func testFailedUpdateEncodingLeavesExistingValueUnchanged() throws {
        let key = makeKey()
        try sut.save(key: key, value: "original")

        XCTAssertThrowsError(try sut.update(key: key, value: Double.infinity)) { error in
            guard case KeyChainStorageError.encodingFailed = error else {
                XCTFail("Expected encodingFailed, got \(error)")
                return
            }
        }
        let actual: String = try sut.read(key: key)
        XCTAssertEqual(actual, "original")
    }

    private func makeKey() -> String {
        let key = "CoreKeyChainStorageSecurityTests.\(UUID().uuidString)"
        keys.append(key)
        return key
    }

    private func query(_ key: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key]
    }
}

private struct StoredPayload: Codable, Equatable {
    let token: String
    let isComplete: Bool
    let groups: [Int]
}
