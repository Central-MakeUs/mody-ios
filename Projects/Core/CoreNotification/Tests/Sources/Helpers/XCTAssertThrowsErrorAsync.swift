//  XCTAssertThrowsErrorAsync.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import XCTest

func XCTAssertThrowsErrorAsync<T>(
    _ expression: () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line,
    verify: (Error) -> Void
) async {
    do {
        _ = try await expression()
        XCTFail("오류가 발생해야 합니다", file: file, line: line)
    } catch {
        verify(error)
    }
}
