//  AuthSessionCleanupTests.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CoreKeyChainStorageInterface
import XCTest
@testable import CoreAuth

final class AuthSessionCleanupTests: XCTestCase {
    private let cleanupKeys = [
        "accessToken", "refreshToken", "isSignUpDone", "mainAccessible",
        "groupOnboardingCompleted", "socialLoginType", "fcmToken"
    ]

    func testLogoutReadsRefreshTokenBeforeNetworkAndDeletesSessionAndFCMOnlyAfterSuccess() async throws {
        for token in ["refresh", ""] {
            let network = AuthNetworkSpy()
            let storage = populatedStorage()
            storage.values["refreshToken"] = token
            network.onRequest = { _ in
                XCTAssertEqual(storage.readKeys, ["refreshToken"])
                XCTAssertTrue(storage.deletedKeys.isEmpty)
                XCTAssertNotNil(storage.values["accessToken"])
            }
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

            try await sut.postLogout()

            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertEqual(network.endpoints.first?.bodyParameters as? [String: String], ["refreshToken": token])
            XCTAssertEqual(storage.deletedKeys, cleanupKeys)
            XCTAssertEqual(Set(storage.values.keys), ["unrelated"])
            XCTAssertTrue(storage.savedKeys.isEmpty)
            XCTAssertTrue(storage.updatedKeys.isEmpty)
        }
    }

    func testLogoutMissingOrWrongTypeRefreshTokenSkipsNetworkAndCleanup() async {
        for value: Any? in [nil, 123] {
            let network = AuthNetworkSpy()
            let storage = populatedStorage()
            storage.values["refreshToken"] = value
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)
            await XCTAssertThrowsErrorAsync({ try await sut.postLogout() }) {
                guard case KeyChainStorageError.noMatchKeyError = $0 else { return XCTFail("Unexpected error: \($0)") }
            }
            XCTAssertEqual(storage.readKeys, ["refreshToken"])
            XCTAssertTrue(network.endpoints.isEmpty)
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertNotNil(storage.values["accessToken"])
        }
    }

    func testLogoutPropagatesKeychainReadErrorsBeforeNetworkOrCleanup() async {
        for error in [AuthTestError.expected as Error, KeyChainStorageError.decodingFailed, CancellationError()] {
            let network = AuthNetworkSpy()
            let storage = populatedStorage()
            storage.readError = error
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)
            await XCTAssertThrowsErrorAsync({ try await sut.postLogout() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(storage.readKeys, ["refreshToken"])
            XCTAssertTrue(network.endpoints.isEmpty)
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertEqual(storage.values.count, 8)
        }
    }

    func testLogoutNetworkErrorAndCancellationPreserveAllStoredValues() async {
        for error in [AuthTestError.expected as Error, CancellationError()] {
            let network = AuthNetworkSpy()
            network.error = error
            let storage = populatedStorage()
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)
            await XCTAssertThrowsErrorAsync({ try await sut.postLogout() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertEqual(storage.readKeys, ["refreshToken"])
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertEqual(storage.values.count, 8)
        }
    }

    func testDeleteAccountDoesNotReadRefreshTokenAndCleansUpOnlyAfterNetworkSuccess() async throws {
        let network = AuthNetworkSpy()
        let storage = populatedStorage()
        storage.values.removeValue(forKey: "refreshToken")
        storage.readError = AuthTestError.unexpectedCall
        network.onRequest = { _ in
            XCTAssertTrue(storage.readKeys.isEmpty)
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertNotNil(storage.values["accessToken"])
        }
        let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

        try await sut.deleteAccount()

        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(network.endpoints.first?.method, .DELETE)
        XCTAssertEqual(storage.deletedKeys, cleanupKeys)
        XCTAssertEqual(Set(storage.values.keys), ["unrelated"])
        XCTAssertTrue(storage.readKeys.isEmpty)
        XCTAssertTrue(storage.savedKeys.isEmpty)
        XCTAssertTrue(storage.updatedKeys.isEmpty)
    }

    func testDeleteAccountNetworkErrorAndCancellationPreserveAllStoredValues() async {
        for error in [AuthTestError.expected as Error, CancellationError()] {
            let network = AuthNetworkSpy()
            network.error = error
            let storage = populatedStorage()
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)
            await XCTAssertThrowsErrorAsync({ try await sut.deleteAccount() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertTrue(storage.readKeys.isEmpty)
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertEqual(storage.values.count, 8)
        }
    }

    func testLogoutAndDeletionIgnoreEveryCombinationOfDeleteFailuresAndAttemptAllSevenKeys() async throws {
        // 7개 삭제 키의 성공/실패 조합 128개를 logout과 deleteAccount 각각 검증한다.
        for logout in [true, false] {
            for mask in 0..<128 {
                let network = AuthNetworkSpy()
                let storage = populatedStorage()
                storage.failingDeleteKeys = Set(cleanupKeys.enumerated().compactMap { mask & (1 << $0.offset) != 0 ? $0.element : nil })
                let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

                if logout { try await sut.postLogout() } else { try await sut.deleteAccount() }

                XCTAssertEqual(storage.deletedKeys, cleanupKeys, "logout=\(logout), mask=\(mask)")
                XCTAssertEqual(Set(storage.values.keys), storage.failingDeleteKeys.union(["unrelated"]))
                XCTAssertEqual(storage.readKeys, logout ? ["refreshToken"] : [])
                XCTAssertTrue(storage.savedKeys.isEmpty)
                XCTAssertTrue(storage.updatedKeys.isEmpty)
                XCTAssertEqual(network.endpoints.count, 1)
            }
        }
    }

    func testMalformedLogoutOrDeletionResponseSkipsCleanup() async {
        for logout in [true, false] {
            let network = AuthNetworkSpy(responseJSON: "not JSON")
            let storage = populatedStorage()
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)
            await XCTAssertThrowsErrorAsync({
                if logout { try await sut.postLogout() } else { try await sut.deleteAccount() }
            }) { XCTAssertTrue($0 is DecodingError) }
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertEqual(storage.values.count, 8)
            XCTAssertEqual(network.endpoints.count, 1)
        }
    }

    private func populatedStorage() -> AuthKeyChainSpy {
        let storage = AuthKeyChainSpy()
        storage.values = Dictionary(uniqueKeysWithValues: cleanupKeys.map { ($0, "stored-\($0)") })
        storage.values["unrelated"] = "keep"
        return storage
    }
}
