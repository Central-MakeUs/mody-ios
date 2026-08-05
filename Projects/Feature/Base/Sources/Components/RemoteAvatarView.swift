//
//  RemoteAvatarView.swift
//  Base
//
//  Created by 김동준 on 8/3/26.
//

import CommonDomain
import CoreModyImageInterface
import DesignSystem
import Foundation
import SwiftUI
import UIKit

public struct RemoteAvatarView: View {
    @State private var imagePhase: ImagePhase = .empty

    private let imageLoader: RemoteImageLoading
    private let localImage: UIImage?
    private let defaultAvatar: DefaultAvatar
    private let width: CGFloat
    private let height: CGFloat
    private let hasStroke: Bool
    private let imageRequest: RemoteImageRequest?

    public init(
        imageURL: URL?,
        localImage: UIImage? = nil,
        defaultAvatar: DefaultAvatar,
        width: CGFloat,
        height: CGFloat,
        hasStroke: Bool = false,
        imageLoader: RemoteImageLoading
    ) {
        self.imageLoader = imageLoader
        self.localImage = localImage
        self.defaultAvatar = defaultAvatar
        self.width = width
        self.height = height
        self.hasStroke = hasStroke

        let maximumPixelSize = max(width, height) * UIScreen.main.scale
        if let imageURL, maximumPixelSize.isFinite, maximumPixelSize > 0 {
            self.imageRequest = RemoteImageRequest(
                url: imageURL,
                variantIdentifier: "remote-avatar",
                maximumPixelSize: Int(maximumPixelSize.rounded(.up))
            )
        } else {
            self.imageRequest = nil
        }
    }

    public var body: some View {
        Group {
            if let localImage {
                Image(uiImage: localImage)
                    .resizable()
                    .scaledToFill()
            } else if imageRequest != nil {
                switch imagePhase {
                case let .success(image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()

                case .empty, .loading:
                    SkeletonView(width: width, height: height)
                        .clipShape(Circle())

                case .failure:
                    defaultAvatarImage
                }
            } else {
                defaultAvatarImage
            }
        }
        .frame(width: width, height: height)
        .clipShape(Circle())
        .overlay {
            if hasStroke {
                Circle()
                    .strokeBorder(Color.gray2, lineWidth: 2)
            }
        }
        .task(id: imageRequest?.identity) {
            guard localImage == nil else { return }
            await loadImage(for: imageRequest)
        }
    }
}

private extension RemoteAvatarView {
    var defaultAvatarImage: some View {
        defaultAvatar.image
            .resizable()
            .renderingMode(.original)
            .scaledToFill()
    }

    enum ImagePhase {
        case empty
        case loading
        case success(UIImage)
        case failure
    }

    @MainActor
    func loadImage(for request: RemoteImageRequest?) async {
        guard let request else {
            imagePhase = .empty
            return
        }

        imagePhase = .loading

        if let cachedImage = imageLoader.cachedImage(for: request) {
            imagePhase = .success(cachedImage)
            return
        }

        do {
            let image = try await imageLoader.loadImage(with: request)
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

private extension DefaultAvatar {
    var image: Image {
        switch self {
        case .poutBlack:
            Image.icModyAvatarPoutBlack
        case .poutLight:
            Image.icModyAvatarPoutLight
        case .smileBlack:
            Image.icModyAvatarSmileBlack
        case .smileLight:
            Image.icModyAvatarSmileLight
        case .surpriseBlack:
            Image.icModyAvatarSurpriseBlack
        case .surpriseLight:
            Image.icModyAvatarSurpriseLight
        }
    }
}
