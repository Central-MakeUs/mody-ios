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

    func testNormalizedCropRejectsNonFiniteAndEmptyRegions() {
        let invalid: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (.nan, 0, 1, 1), (0, .infinity, 1, 1), (0, 0, .nan, 1), (0, 0, 1, -.infinity),
            (0, 0, 0, 1), (0, 0, -1, 1), (0, 0, 1, 0), (0, 0, 1, -1),
            (1, 0, 1, 1), (0, 1, 1, 1), (2, 0, 1, 1)
        ]
        for (x, y, width, height) in invalid {
            XCTAssertNil(NormalizedImageCropInfo(x: x, y: y, width: width, height: height))
        }
    }

    func testRequestLowerDecodeBoundAndPortraitScaling() {
        let minimum = RemoteImageRequest(url: url, variantIdentifier: "min", maximumPixelSize: -10)
        XCTAssertEqual(minimum.maximumPixelSize, 1)
        XCTAssertEqual(minimum.processing, .none)
        XCTAssertEqual(minimum.identity, "https://example.com/image.jpg|min|decode=1|processing=none")
        let portrait = RemoteImageRequest(
            url: url, variantIdentifier: "portrait", maximumPixelSize: 640,
            processing: .aspectFill(pixelSize: CGSize(width: 400, height: 1200), normalizedCrop: nil)
        )
        XCTAssertEqual(portrait.processing, .aspectFill(pixelSize: CGSize(width: 214, height: 640), normalizedCrop: nil))
        XCTAssertTrue(portrait.identity.hasSuffix("output=214x640|crop=none"))
    }

    func testRequestIdentityAndHashSeparateAllCacheInputs() throws {
        let crop = try XCTUnwrap(NormalizedImageCropInfo(x: 0.2, y: 0.3, width: 0.4, height: 0.5))
        let original = RemoteImageRequest(url: url, variantIdentifier: "a", maximumPixelSize: 640)
        let variants = [
            original,
            RemoteImageRequest(url: URL(string: "https://example.com/other.jpg")!, variantIdentifier: "a", maximumPixelSize: 640),
            RemoteImageRequest(url: url, variantIdentifier: "b", maximumPixelSize: 640),
            RemoteImageRequest(url: url, variantIdentifier: "a", maximumPixelSize: 320),
            RemoteImageRequest(url: url, variantIdentifier: "a", maximumPixelSize: 640, processing: .aspectFill(pixelSize: CGSize(width: 10, height: 20), normalizedCrop: nil)),
            RemoteImageRequest(url: url, variantIdentifier: "a", maximumPixelSize: 640, processing: .aspectFill(pixelSize: CGSize(width: 10, height: 20), normalizedCrop: crop))
        ]
        XCTAssertEqual(Set(variants).count, variants.count)
        XCTAssertEqual(Set(variants.map(\.identity)).count, variants.count)
        XCTAssertEqual(original, RemoteImageRequest(url: url, variantIdentifier: "a", maximumPixelSize: 640))
    }

    func testRequestSanitizesZeroAndNegativeOutputDimensions() {
        let request = RemoteImageRequest(
            url: url, variantIdentifier: "zero", maximumPixelSize: 0,
            processing: .aspectFill(pixelSize: CGSize(width: 0, height: -10), normalizedCrop: nil)
        )
        XCTAssertEqual(request.processing, .aspectFill(pixelSize: CGSize(width: 1, height: 1), normalizedCrop: nil))
    }

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
