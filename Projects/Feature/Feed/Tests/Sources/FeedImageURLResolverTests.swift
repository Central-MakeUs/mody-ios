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

    func testResolveUsesNestedImageURL() {
        XCTAssertEqual(
            FeedImageURLResolver.resolve(
                "https://proxy.example.com/https://image.example.com/photo.jpg"
            )?.absoluteString,
            "https://image.example.com/photo.jpg"
        )
    }

    func testResolveUpgradesNestedHTTPURL() {
        XCTAssertEqual(
            FeedImageURLResolver.resolve(
                "https://proxy.example.com/http://image.example.com/photo.jpg"
            )?.absoluteString,
            "https://image.example.com/photo.jpg"
        )
    }

    func testResolveReturnsNilForEmptyString() {
        XCTAssertNil(FeedImageURLResolver.resolve("   "))
    }
}
