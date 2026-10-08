//  XCTAssertThrowsErrorAsync.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import XCTest

func XCTAssertThrowsErrorAsync<T>(
    _ expression: () async throws -> T,
    isolation: isolated (any Actor)? = #isolation,
    file: StaticString = #filePath,
    line: UInt = #line,
    verify: (Error) -> Void
) async {
    do {
        _ = try await expression()
        XCTFail("Expected an error", file: file, line: line)
    } catch {
        verify(error)
    }
}
