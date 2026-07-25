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

    func testRequestBoundsDecodeAndProcessingPixelSizes() {
        let request = RemoteImageRequest(
            url: url,
            variantIdentifier: "oversized",
            maximumPixelSize: 10_000,
            processing: .aspectFill(
                pixelSize: CGSize(width: 8_000, height: 4_000),
                normalizedCrop: nil
            )
        )

        XCTAssertEqual(
            request.maximumPixelSize,
            RemoteImageRequest.maximumAllowedPixelSize
        )

        guard case let .aspectFill(pixelSize, _) = request.processing else {
            return XCTFail("Expected bounded aspect-fill processing")
        }
        XCTAssertEqual(pixelSize, CGSize(width: 2048, height: 1024))
    }

    func testRequestSanitizesInvalidProcessingPixelSizes() {
        let request = RemoteImageRequest(
            url: url,
            variantIdentifier: "invalid-size",
            maximumPixelSize: 2048,
            processing: .aspectFill(
                pixelSize: CGSize(
                    width: CGFloat.infinity,
                    height: CGFloat.nan
                ),
                normalizedCrop: nil
            )
        )

        guard case let .aspectFill(pixelSize, _) = request.processing else {
            return XCTFail("Expected sanitized aspect-fill processing")
        }
        XCTAssertEqual(pixelSize, CGSize(width: 1, height: 1))
    }

    func testPipelineMemoryAndResponseLimitsStayBounded() {
        XCTAssertEqual(
            NukeRemoteImageLoader.memoryCacheCostLimit,
            32 * 1024 * 1024
        )
        XCTAssertEqual(NukeRemoteImageLoader.memoryCacheCountLimit, 100)
        XCTAssertEqual(NukeRemoteImageLoader.memoryCacheEntryCostLimit, 0.25)
        XCTAssertEqual(
            NukeRemoteImageLoader.maximumResponseDataSize,
            32 * 1024 * 1024
        )
        XCTAssertEqual(NukeRemoteImageLoader.httpMemoryCacheCapacity, 0)

        let configuration = NukeRemoteImageLoader.makePipeline().configuration
        XCTAssertFalse(configuration.isResumableDataEnabled)
        XCTAssertFalse(configuration.isProgressiveDecodingEnabled)
    }
}
