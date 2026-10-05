//
//  FeedDemoImageLoaderStub.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import CoreModyImage
import CoreModyImageInterface
import Foundation
import UIKit

final class FeedDemoImageLoaderStub: RemoteImageLoading, @unchecked Sendable {
    private let imageLoader = NukeRemoteImageLoader()

    func cachedImage(for request: RemoteImageRequest) -> UIImage? { nil }

    func loadImage(with request: RemoteImageRequest) async throws -> UIImage {
        try await Task.sleep(for: .milliseconds(500))
        let name = request.url.deletingLastPathComponent().lastPathComponent == "exercise"
            ? "FeedDemoExercise" : "FeedDemoMeal"
        guard let url = Bundle.main.url(forResource: name, withExtension: "jpg") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try await imageLoader.loadImage(with: RemoteImageRequest(
            url: url,
            variantIdentifier: request.variantIdentifier,
            maximumPixelSize: request.maximumPixelSize,
            processing: request.processing
        ))
    }
}
