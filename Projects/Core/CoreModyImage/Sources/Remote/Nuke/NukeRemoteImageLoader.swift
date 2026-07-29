//
//  NukeRemoteImageLoader.swift
//  CoreModyImage
//
//  Created by 김동준 on 7/25/26.
//

import CoreModyImageInterface
import Foundation
import Nuke
import UIKit

/// 제한된 메모리 캐시와 HTTP 캐시를 공유하는 앱 공용 Nuke 이미지 로더입니다.
public final class NukeRemoteImageLoader: RemoteImageLoading, @unchecked Sendable {
    public static let shared = NukeRemoteImageLoader()

    public static let memoryCacheCostLimit = 32 * 1024 * 1024
    public static let memoryCacheCountLimit = 100
    public static let memoryCacheEntryCostLimit = 0.25
    public static let maximumResponseDataSize = 32 * 1024 * 1024
    public static let httpMemoryCacheCapacity = 0
    public static let httpDiskCacheCapacity = 200 * 1024 * 1024

    private let pipeline: ImagePipeline

    public init() {
        self.pipeline = Self.makePipeline()
    }

    init(pipeline: ImagePipeline) {
        self.pipeline = pipeline
    }

    public func cachedImage(for request: RemoteImageRequest) -> UIImage? {
        // 동기 조회는 디코딩·가공이 끝난 메모리 이미지에만 한정합니다.
        pipeline.cache.cachedImage(
            for: makeNukeRequest(for: request),
            caches: [.memory]
        )?.image
    }

    public func loadImage(with request: RemoteImageRequest) async throws -> UIImage {
        let imageTask = pipeline.imageTask(with: makeNukeRequest(for: request))

        return try await withTaskCancellationHandler {
            try await imageTask.image
        } onCancel: {
            imageTask.cancel()
        }
    }
}

extension NukeRemoteImageLoader {
    func makeNukeRequest(for request: RemoteImageRequest) -> ImageRequest {
        var imageRequest = ImageRequest(
            url: request.url,
            processors: makeProcessors(for: request.processing)
        )
        imageRequest.imageID = request.identity
        // 원본 전체 해상도 디코딩을 피하고 화면 용도에 필요한 크기로 다운샘플링합니다.
        imageRequest.thumbnail = ImageRequest.ThumbnailOptions(
            maxPixelSize: Float(request.maximumPixelSize)
        )
        return imageRequest
    }
}

private extension NukeRemoteImageLoader {
    func makeProcessors(
        for processing: RemoteImageProcessing
    ) -> [any ImageProcessing] {
        switch processing {
        case .none:
            return []

        case let .aspectFill(pixelSize, normalizedCrop):
            return [
                NormalizedCropProcessor(
                    normalizedCrop: normalizedCrop,
                    outputPixelSize: pixelSize
                )
            ]
        }
    }
}

extension NukeRemoteImageLoader {
    static func makePipeline() -> ImagePipeline {
        // 디코딩·가공된 UIImage는 메모리에만 보관하며 비용과 개수를 모두 제한합니다.
        let imageCache = ImageCache(
            costLimit: memoryCacheCostLimit,
            countLimit: memoryCacheCountLimit
        )
        imageCache.entryCostLimit = memoryCacheEntryCostLimit

        // 원본 응답 데이터는 decoded UIImage와 중복 보관하지 않고 디스크에만 캐싱합니다.
        let urlCache = URLCache(
            memoryCapacity: httpMemoryCacheCapacity,
            diskCapacity: httpDiskCacheCapacity,
            diskPath: "com.mody.remote.images"
        )
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = urlCache
        sessionConfiguration.requestCachePolicy = .useProtocolCachePolicy

        var configuration = ImagePipeline.Configuration(
            dataLoader: DataLoader(configuration: sessionConfiguration)
        )
        configuration.imageCache = imageCache
        // 같은 원본 데이터를 별도 Nuke DataCache에도 중복 저장하지 않습니다.
        configuration.dataCache = nil
        configuration.maximumResponseDataSize = maximumResponseDataSize
        // 동시에 들어온 동일 요청은 한 작업으로 합쳐 중복 다운로드·가공을 방지합니다.
        configuration.isTaskCoalescingEnabled = true
        // 취소된 다운로드의 부분 Data를 별도 메모리 캐시에 남기지 않습니다.
        configuration.isResumableDataEnabled = false
        configuration.isProgressiveDecodingEnabled = false

        return ImagePipeline(configuration: configuration)
    }
}
