//
//  RemoteImageLoaderStub.swift
//  CoreModyImageTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreModyImageInterface
import UIKit

public final class RemoteImageLoaderStub: RemoteImageLoading {
    private let cachedHandler: @Sendable (RemoteImageRequest) -> UIImage?
    private let loadHandler: @Sendable (RemoteImageRequest) async throws -> UIImage
    private let responseDelay: Duration

    public init(
        cachedImage: @escaping @Sendable (RemoteImageRequest) -> UIImage? = { _ in nil },
        loadImage: @escaping @Sendable (RemoteImageRequest) async throws -> UIImage = { _ in
            throw CoreModyImageStubError.unexpectedCall("loadImage")
        },
        responseDelay: Duration = .zero
    ) {
        self.cachedHandler = cachedImage
        self.loadHandler = loadImage
        self.responseDelay = responseDelay
    }

    public func cachedImage(for request: RemoteImageRequest) -> UIImage? {
        cachedHandler(request)
    }

    public func loadImage(with request: RemoteImageRequest) async throws -> UIImage {
        if responseDelay > .zero {
            try await Task.sleep(for: responseDelay)
        }
        return try await loadHandler(request)
    }
}
