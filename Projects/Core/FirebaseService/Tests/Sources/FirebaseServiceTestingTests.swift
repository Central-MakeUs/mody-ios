//  FirebaseServiceTestingTests.swift
//  FirebaseServiceTests
//
//  Created by 김동준 on 10/9/26.
//

import FirebaseServiceInterface
import FirebaseServiceTesting
import XCTest

final class FirebaseServiceTestingTests: XCTestCase {
    func testUnconfiguredValuesMatchRemoteConfigFallbacks() async throws {
        let sut: FirebaseServiceInterface = FirebaseServiceStub()

        try await sut.fetchAndActivate()

        XCTAssertEqual(sut.getString(forKey: "missing"), "")
        XCTAssertFalse(sut.getBool(forKey: "missing"))
        XCTAssertNil(sut.getJson(forKey: "missing", as: [String].self))
    }

    func testValuesAreSelectedByKeyAndType() {
        let sut = FirebaseServiceStub(
            strings: ["title": "공지", "version": "1.0.0"],
            bools: ["enabled": true, "disabled": false],
            jsonValues: ["items": ["first", "second"], "count": 2]
        )

        XCTAssertEqual(sut.getString(forKey: "title"), "공지")
        XCTAssertEqual(sut.getString(forKey: "version"), "1.0.0")
        XCTAssertTrue(sut.getBool(forKey: "enabled"))
        XCTAssertFalse(sut.getBool(forKey: "disabled"))
        XCTAssertFalse(sut.getBool(forKey: "title"))
        XCTAssertEqual(sut.getJson(forKey: "items", as: [String].self), ["first", "second"])
        XCTAssertEqual(sut.getJson(forKey: "count", as: Int.self), 2)
        XCTAssertNil(sut.getJson(forKey: "items", as: Int.self))
    }

    func testStubInstancesDoNotShareValues() {
        let first = FirebaseServiceStub(strings: ["key": "first"], bools: ["key": true])
        let second = FirebaseServiceStub(strings: ["key": "second"])

        XCTAssertEqual(first.getString(forKey: "key"), "first")
        XCTAssertEqual(second.getString(forKey: "key"), "second")
        XCTAssertTrue(first.getBool(forKey: "key"))
        XCTAssertFalse(second.getBool(forKey: "key"))
    }

    func testFetchAwaitsHandlerOnEveryCall() async throws {
        let calls = FetchCalls()
        let sut = FirebaseServiceStub(fetchAndActivate: { await calls.record() })

        try await sut.fetchAndActivate()
        try await sut.fetchAndActivate()

        let count = await calls.count
        XCTAssertEqual(count, 2)
    }

    func testFetchPropagatesHandlerError() async {
        let sut = FirebaseServiceStub(fetchAndActivate: { throw FetchError.expected })

        do {
            try await sut.fetchAndActivate()
            XCTFail("Expected the injected failure")
        } catch {
            XCTAssertEqual(error as? FetchError, .expected)
        }
    }

    func testFetchPreservesCancellation() async {
        let sut = FirebaseServiceStub(fetchAndActivate: { throw CancellationError() })

        do {
            try await sut.fetchAndActivate()
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }
}

private actor FetchCalls {
    private(set) var count = 0

    func record() {
        count += 1
    }
}

private enum FetchError: Error {
    case expected
}
