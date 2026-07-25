//
//  FeedImageTargetSizeTests.swift
//  FeedTests
//
//  Created by 김동준 on 7/25/26.
//

import XCTest
@testable import Feed

final class FeedImageTargetSizeTests: XCTestCase {
    func testTargetSizeUsesSmallestBucketContainingDisplayPixels() throws {
        let targetSize = try XCTUnwrap(
            FeedImageTargetSize.make(
                displaySize: CGSize(width: 100, height: 50),
                displayScale: 2
            )
        )

        XCTAssertEqual(targetSize.longSideBucket, 256)
        XCTAssertEqual(targetSize.pixelSize, CGSize(width: 256, height: 128))
    }

    func testTargetSizeCapsLongSideAtLargestBucket() throws {
        let targetSize = try XCTUnwrap(
            FeedImageTargetSize.make(
                displaySize: CGSize(width: 500, height: 300),
                displayScale: 3
            )
        )

        XCTAssertEqual(targetSize.longSideBucket, 1024)
        XCTAssertEqual(targetSize.pixelSize.width, 1024)
        XCTAssertEqual(targetSize.pixelSize.height, 615)
    }

    func testTargetSizeRejectsEmptyDisplaySize() {
        XCTAssertNil(
            FeedImageTargetSize.make(
                displaySize: .zero,
                displayScale: 3
            )
        )
    }
}
