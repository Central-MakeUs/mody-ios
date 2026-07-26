//
//  ProfileAvatarView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import CommonDomain
import CoreModyImageInterface
import DesignSystem
import Foundation
import SwiftUI
import UIKit

struct ProfileAvatarView: View {
    @State private var imagePhase: ImagePhase = .empty

    let defaultAvatar: DefaultAvatar
    let size: CGSize
    let hasStroke: Bool
    let imageLoader: RemoteImageLoading
    private let imageRequest: RemoteImageRequest?

    init(
        imageURL: URL?,
        defaultAvatar: DefaultAvatar,
        size: CGSize = .init(width: 50, height: 50),
        hasStroke: Bool = false,
        imageLoader: RemoteImageLoading
    ) {
        self.defaultAvatar = defaultAvatar
        self.size = size
        self.hasStroke = hasStroke
        self.imageLoader = imageLoader

        let maximumPixelSize = max(size.width, size.height) * UIScreen.main.scale
        if let imageURL, maximumPixelSize.isFinite, maximumPixelSize > 0 {
            self.imageRequest = RemoteImageRequest(
                url: imageURL,
                variantIdentifier: "my-page-profile",
                maximumPixelSize: Int(maximumPixelSize.rounded(.up))
            )
        } else {
            self.imageRequest = nil
        }
    }

    var body: some View {
        Group {
            if imageRequest != nil {
                switch imagePhase {
                case let .success(image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()

                case .empty, .loading:
                    SkeletonView(width: size.width, height: size.height)
                        .clipShape(Circle())

                case .failure:
                    defaultAvatarImage
                }
            } else {
                defaultAvatarImage
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(Circle())
        .overlay {
            if hasStroke {
                Circle()
                    .strokeBorder(Color.gray2, lineWidth: 2)
            }
        }
        .task(id: imageRequest?.identity) {
            await loadImage(for: imageRequest)
        }
    }
}

private extension ProfileAvatarView {
    var defaultAvatarImage: some View {
        defaultAvatar.image
            .resizable()
            .renderingMode(.original)
            .scaledToFill()
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

private extension ProfileAvatarView {
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
