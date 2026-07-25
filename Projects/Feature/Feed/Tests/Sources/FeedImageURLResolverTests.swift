//
//  FeedImageURLResolverTests.swift
//  FeedTests
//
//  Created by 김동준 on 7/25/26.
//

import XCTest
@testable import Feed

final class FeedImageURLResolverTests: XCTestCase {
    func testResolveTrimsWhitespace() {
        XCTAssertEqual(
            FeedImageURLResolver.resolve("  https://example.com/image.jpg  ")?.absoluteString,
            "https://example.com/image.jpg"
        )
    }

    func testResolveReturnsNilForRelativeURL() {
        XCTAssertNil(FeedImageURLResolver.resolve("image.jpg"))
    }

    func testResolveReturnsNilForUnsupportedScheme() {
        XCTAssertNil(FeedImageURLResolver.resolve("file:///tmp/image.jpg"))
    }

    func testResolveReturnsNilForEmptyString() {
        XCTAssertNil(FeedImageURLResolver.resolve("   "))
    }
}
