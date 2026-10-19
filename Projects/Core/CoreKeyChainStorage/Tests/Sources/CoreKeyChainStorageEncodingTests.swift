//
//  CoreKeyChainStorageEncodingTests.swift
//  CoreKeyChainStorageTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreKeyChainStorage
import CoreKeyChainStorageInterface
import Foundation
import XCTest

final class CoreKeyChainStorageEncodingTests: XCTestCase {
    private let sut = CoreKeyChainStorage()

    func testSaveMapsEncodableFailureToEncodingFailed() {
        assertEncodingFailed {
            try sut.save(key: testKey(), value: FailingEncodable())
        }
    }

    func testUpdateMapsEncodableFailureToEncodingFailed() {
        assertEncodingFailed {
            try sut.update(key: testKey(), value: FailingEncodable())
        }
    }

    func testSaveRejectsNonFiniteNumbers() {
        for value in [Double.nan, .infinity, -.infinity] {
            assertEncodingFailed {
                try sut.save(key: testKey(), value: value)
            }
        }
    }

    func testUpdateRejectsNonFiniteNumbers() {
        for value in [Double.nan, .infinity, -.infinity] {
            assertEncodingFailed {
                try sut.update(key: testKey(), value: value)
            }
        }
    }

    private func testKey() -> String {
        "CoreKeyChainStorageEncodingTests.\(UUID().uuidString)"
    }

    private func assertEncodingFailed(
        _ operation: () throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try operation(), file: file, line: line) { error in
            guard case KeyChainStorageError.encodingFailed = error else {
                XCTFail("Expected encodingFailed, got \(error)", file: file, line: line)
                return
            }
        }
    }
}

private struct FailingEncodable: Encodable {
    func encode(to encoder: any Encoder) throws {
        throw EncodingError.invalidValue(
            self,
            .init(codingPath: encoder.codingPath, debugDescription: "Deliberate encoding failure")
        )
    }
}
