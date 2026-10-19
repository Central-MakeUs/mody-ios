//
//  XCTestCase+NetworkError.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import CommonDomain
import XCTest

extension XCTestCase {
    func assertNetworkError(
        _ expected: NetworkError,
        file: StaticString = #filePath,
        line: UInt = #line,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected \(expected)", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? NetworkError, expected, file: file, line: line)
        }
    }
}
