//
//  CoreModyImageRequestTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import XCTest
@testable import CoreModyImage

final class CoreModyImageRequestTests: XCTestCase {
    private let url = URL(string: "https://example.com/image.jpg")!

    func testNormalizedCropClampsValuesToUnitBounds() throws {
        let crop = try XCTUnwrap(
            NormalizedImageCropInfo(
                x: -0.1,
                y: 0.25,
                width: 1.2,
                height: 1
            )
        )

        XCTAssertEqual(crop.x, 0)
        XCTAssertEqual(crop.y, 0.25)
        XCTAssertEqual(crop.width, 1)
        XCTAssertEqual(crop.height, 0.75)
    }

    func testRequestIdentityIncludesDecodeAndProcessingPolicy() throws {
        let crop = try XCTUnwrap(
            NormalizedImageCropInfo(
                x: 0.1234567,
                y: 0.2,
                width: 0.5,
                height: 0.6
            )
        )
        let request = RemoteImageRequest(
            url: url,
            variantIdentifier: "record",
            maximumPixelSize: 2048,
            processing: .aspectFill(
                pixelSize: CGSize(width: 1024, height: 568),
                normalizedCrop: crop
            )
        )

        XCTAssertTrue(request.identity.contains("record"))
        XCTAssertTrue(request.identity.contains("decode=2048"))
        XCTAssertTrue(request.identity.contains("output=1024x568"))
        XCTAssertTrue(request.identity.contains("0.123457"))
        XCTAssertTrue(request.identity.contains("aspect-fill-v1"))
    }

    func testNukeRequestUsesBoundedThumbnailAndProcessor() throws {
        let request = RemoteImageRequest(
            url: url,
            variantIdentifier: "record",
            maximumPixelSize: 2048,
            processing: .aspectFill(
                pixelSize: CGSize(width: 512, height: 512),
                normalizedCrop: nil
            )
        )

        let nukeRequest = NukeRemoteImageLoader().makeNukeRequest(for: request)

        XCTAssertNotNil(nukeRequest.thumbnail)
        XCTAssertEqual(nukeRequest.processors.count, 1)
        XCTAssertEqual(nukeRequest.imageID, request.identity)
    }

    func testPipelineMemoryAndResponseLimitsStayBounded() {
        XCTAssertEqual(
            NukeRemoteImageLoader.memoryCacheCostLimit,
            64 * 1024 * 1024
        )
        XCTAssertEqual(NukeRemoteImageLoader.memoryCacheCountLimit, 100)
        XCTAssertEqual(
            NukeRemoteImageLoader.maximumResponseDataSize,
            32 * 1024 * 1024
        )
    }
}
