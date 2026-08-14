//
//  ChallengeWeeklyProofImage.swift
//  Challenge
//
//  Created by 김동준 on 8/13/26.
//

import CoreModyImageInterface
import DesignSystem
import Foundation
import SwiftUI
import UIKit

struct ChallengeWeeklyProofImage: View {
    @State private var imagePhase: ImagePhase = .empty

    private let imageLoader: RemoteImageLoading
    private let imageRequest: RemoteImageRequest?

    init(
        proof: WeeklyChallengeImageInfo,
        size: CGSize,
        imageLoader: RemoteImageLoading
    ) {
        self.imageLoader = imageLoader

        let trimmedURLString = proof.imageUrl
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let imageURL = URL(string: trimmedURLString)
            ?? trimmedURLString
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                .flatMap(URL.init(string:))
        let scale = UIScreen.main.scale
        let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
        let maximumPixelSize = max(pixelSize.width, pixelSize.height)

        if let imageURL,
           maximumPixelSize.isFinite,
           maximumPixelSize > 0 {
            let cropInfo = proof.imageCropRegion.flatMap {
                NormalizedImageCropInfo(
                    x: $0.x,
                    y: $0.y,
                    width: $0.width,
                    height: $0.height
                )
            }

            self.imageRequest = RemoteImageRequest(
                url: imageURL,
                variantIdentifier: "challenge-weekly-proof-grid",
                maximumPixelSize: RemoteImageRequest.maximumAllowedPixelSize,
                processing: .aspectFill(
                    pixelSize: pixelSize,
                    normalizedCrop: cropInfo
                )
            )
        } else {
            self.imageRequest = nil
        }
    }

    var body: some View {
        Group {
            switch imagePhase {
            case let .success(image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            case .empty, .loading, .failure:
                Color.gray1
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .task(id: imageRequest?.identity) {
            await loadImage()
        }
    }
}

private extension ChallengeWeeklyProofImage {
    enum ImagePhase {
        case empty
        case loading
        case success(UIImage)
        case failure
    }

    @MainActor
    func loadImage() async {
        guard let imageRequest else {
            imagePhase = .failure
            return
        }

        imagePhase = .loading

        if let cachedImage = imageLoader.cachedImage(for: imageRequest) {
            imagePhase = .success(cachedImage)
            return
        }

        do {
            let image = try await imageLoader.loadImage(with: imageRequest)
            guard !Task.isCancelled else { return }
            imagePhase = .success(image)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            imagePhase = .failure
        }
    }
}
