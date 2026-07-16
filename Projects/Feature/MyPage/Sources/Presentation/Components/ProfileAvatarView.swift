//
//  ProfileAvatarView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import CommonDomain
import DesignSystem
import Foundation
import SwiftUI

struct ProfileAvatarView: View {
    let imageURL: URL?
    let defaultAvatar: DefaultAvatar
    let size: CGSize
    let hasStroke: Bool

    init(
        imageURL: URL?,
        defaultAvatar: DefaultAvatar,
        size: CGSize = .init(width: 50, height: 50),
        hasStroke: Bool = false
    ) {
        self.imageURL = imageURL
        self.defaultAvatar = defaultAvatar
        self.size = size
        self.hasStroke = hasStroke
    }

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty, .failure:
                defaultAvatarImage
            @unknown default:
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
