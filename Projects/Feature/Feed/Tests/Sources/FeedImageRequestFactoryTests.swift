//
//  FeedImageRequestFactoryTests.swift
//  FeedTests
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import XCTest
@testable import Feed

final class FeedImageRequestFactoryTests: XCTestCase {
    private let url = URL(string: "https://example.com/image.jpg")!

    func testRecordRequestUsesBoundedDecodeAndROIProcessor() throws {
        let descriptor = try XCTUnwrap(
            FeedImageRequestFactory.makeRecordRequest(
                url: url,
                cropRegion: FeedImageCropRegion(
                    x: 0.1234567,
                    y: 0.2,
                    width: 0.5,
                    height: 0.6
                ),
                displaySize: CGSize(width: 360, height: 200),
                displayScale: 3
            )
        )

        XCTAssertEqual(descriptor.maximumPixelSize, 2048)
        XCTAssertTrue(descriptor.identity.contains("record"))
        XCTAssertTrue(descriptor.identity.contains("decode=2048"))
        XCTAssertTrue(descriptor.identity.contains("output=2048"))
        XCTAssertTrue(descriptor.identity.contains("0.123457"))
        XCTAssertTrue(descriptor.identity.contains("aspect-fill-v1"))
    }

    func testRecordIdentityChangesWhenROIChanges() throws {
        let first = try makeRecordDescriptor(
            cropRegion: FeedImageCropRegion(x: 0, y: 0, width: 0.5, height: 1)
        )
        let second = try makeRecordDescriptor(
            cropRegion: FeedImageCropRegion(x: 0.5, y: 0, width: 0.5, height: 1)
        )

        XCTAssertNotEqual(first.identity, second.identity)
    }

    func testRecordRequestWaitsForLayout() {
        XCTAssertNil(
            FeedImageRequestFactory.makeRecordRequest(
                url: url,
                cropRegion: nil,
                displaySize: .zero,
                displayScale: 3
            )
        )
    }

}

private extension FeedImageRequestFactoryTests {
    func makeRecordDescriptor(
        cropRegion: FeedImageCropRegion?
    ) throws -> RemoteImageRequest {
        try XCTUnwrap(
            FeedImageRequestFactory.makeRecordRequest(
                url: url,
                cropRegion: cropRegion,
                displaySize: CGSize(width: 360, height: 200),
                displayScale: 3
            )
        )
    }
}
