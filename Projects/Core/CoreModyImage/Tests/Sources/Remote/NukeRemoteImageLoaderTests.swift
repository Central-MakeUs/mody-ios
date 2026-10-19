//
//  NukeRemoteImageLoaderTests.swift
//  CoreModyImageTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import Nuke
import UIKit
import XCTest
@testable import CoreModyImage

final class NukeRemoteImageLoaderTests: XCTestCase {
    private let url = URL(string: "https://image.invalid/source.png")!

    func testCachedImageReturnsOnlyMatchingMemoryEntry() throws {
        let dataLoader = ImageDataLoaderSpy(result: nil)
        let pipeline = makePipeline(dataLoader: dataLoader)
        defer { pipeline.invalidate() }
        let loader = NukeRemoteImageLoader(pipeline: pipeline)
        let request = RemoteImageRequest(url: url, variantIdentifier: "profile", maximumPixelSize: 80)
        let image = ImageFixture.make()
        XCTAssertNil(loader.cachedImage(for: request))
        pipeline.cache.storeCachedImage(ImageContainer(image: image), for: loader.makeNukeRequest(for: request), caches: [.memory])
        XCTAssertTrue(loader.cachedImage(for: request) === image)
        XCTAssertNil(loader.cachedImage(for: RemoteImageRequest(url: url, variantIdentifier: "record", maximumPixelSize: 80)))
        XCTAssertTrue(dataLoader.requestedURLs.isEmpty)
    }

    func testLoadDecodesDataAndAppliesCropAndCachesResult() async throws {
        let data = try XCTUnwrap(ImageFixture.make().pngData())
        let dataLoader = ImageDataLoaderSpy(result: .success(data))
        let pipeline = makePipeline(dataLoader: dataLoader)
        defer { pipeline.invalidate() }
        let loader = NukeRemoteImageLoader(pipeline: pipeline)
        let request = RemoteImageRequest(
            url: url, variantIdentifier: "processed", maximumPixelSize: 80,
            processing: .aspectFill(pixelSize: CGSize(width: 20, height: 20), normalizedCrop: nil)
        )
        let image = try await loader.loadImage(with: request)
        XCTAssertEqual(image.cgImage?.width, 20)
        XCTAssertEqual(image.cgImage?.height, 20)
        XCTAssertNotNil(loader.cachedImage(for: request))
        let again = try await loader.loadImage(with: request)
        XCTAssertEqual(again.cgImage?.width, 20)
        XCTAssertEqual(dataLoader.requestedURLs, [url])
    }

    func testLoadWithoutProcessingUsesThumbnailBounds() async throws {
        let dataLoader = ImageDataLoaderSpy(result: .success(try XCTUnwrap(ImageFixture.make().pngData())))
        let pipeline = makePipeline(dataLoader: dataLoader)
        defer { pipeline.invalidate() }
        let loader = NukeRemoteImageLoader(pipeline: pipeline)
        let request = RemoteImageRequest(url: url, variantIdentifier: "thumbnail", maximumPixelSize: 40)
        XCTAssertTrue(loader.makeNukeRequest(for: request).processors.isEmpty)
        XCTAssertEqual(loader.makeNukeRequest(for: request).thumbnail, ImageRequest.ThumbnailOptions(maxPixelSize: 40))
        let image = try await loader.loadImage(with: request)
        XCTAssertEqual(image.cgImage?.width, 40)
        XCTAssertEqual(image.cgImage?.height, 20)
    }

    func testLoadPropagatesDataLoaderFailureAndDoesNotCache() async {
        let dataLoader = ImageDataLoaderSpy(result: .failure(URLError(.timedOut)))
        let pipeline = makePipeline(dataLoader: dataLoader)
        defer { pipeline.invalidate() }
        let loader = NukeRemoteImageLoader(pipeline: pipeline)
        let request = RemoteImageRequest(url: url, variantIdentifier: "failure", maximumPixelSize: 80)
        do {
            _ = try await loader.loadImage(with: request)
            XCTFail("Expected data loading failure")
        } catch let error as ImagePipeline.Error {
            guard case .dataLoadingFailed(let underlying) = error else {
                return XCTFail("Unexpected pipeline error: \(error)")
            }
            XCTAssertEqual((underlying as? URLError)?.code, .timedOut)
        } catch { XCTFail("Unexpected error: \(error)") }
        XCTAssertNil(loader.cachedImage(for: request))
        XCTAssertEqual(dataLoader.requestedURLs, [url])
    }

    func testLoadRejectsInvalidImageBytes() async {
        let pipeline = makePipeline(dataLoader: ImageDataLoaderSpy(result: .success(Data("invalid".utf8))))
        defer { pipeline.invalidate() }
        do {
            _ = try await NukeRemoteImageLoader(pipeline: pipeline).loadImage(with: RemoteImageRequest(
                url: url, variantIdentifier: "invalid", maximumPixelSize: 80
            ))
            XCTFail("Expected decoding failure")
        } catch let error as ImagePipeline.Error {
            guard case .decodingFailed = error else { return XCTFail("Unexpected error: \(error)") }
        } catch { XCTFail("Unexpected error: \(error)") }
    }

    func testTaskCancellationCancelsUnderlyingImageTask() async {
        let started = expectation(description: "data loading started")
        let cancelled = expectation(description: "data loading cancelled")
        let dataLoader = ImageDataLoaderSpy(result: nil, onStart: { started.fulfill() }, onCancel: { cancelled.fulfill() })
        let pipeline = makePipeline(dataLoader: dataLoader)
        defer { pipeline.invalidate() }
        let loader = NukeRemoteImageLoader(pipeline: pipeline)
        let request = RemoteImageRequest(url: url, variantIdentifier: "cancel", maximumPixelSize: 80)
        let task = Task { try await loader.loadImage(with: request) }
        await fulfillment(of: [started], timeout: 2)
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch let error as ImagePipeline.Error {
            guard case .cancelled = error else { return XCTFail("Unexpected error: \(error)") }
        } catch { XCTFail("Unexpected error: \(error)") }
        await fulfillment(of: [cancelled], timeout: 2)
        XCTAssertNil(loader.cachedImage(for: request))
    }

    private func makePipeline(dataLoader: any DataLoading) -> ImagePipeline {
        var configuration = ImagePipeline.Configuration(dataLoader: dataLoader)
        configuration.imageCache = ImageCache()
        configuration.dataCache = nil
        configuration.isResumableDataEnabled = false
        configuration.isRateLimiterEnabled = false
        return ImagePipeline(configuration: configuration)
    }
}
