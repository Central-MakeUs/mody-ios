//
//  ChallengeWeeklyProofItem.swift
//  Challenge
//
//  Created by 김동준 on 8/13/26.
//

import Base
import CommonDomain
import CoreModyImageInterface
import DesignSystem
import Foundation
import SwiftUI

struct ChallengeWeeklyProofItem: View {
    private let proof: WeeklyChallengeImageInfo
    private let itemSize: CGFloat
    private let imageLoader: RemoteImageLoading

    init(
        proof: WeeklyChallengeImageInfo,
        itemSize: CGFloat,
        imageLoader: RemoteImageLoading
    ) {
        self.proof = proof
        self.itemSize = itemSize
        self.imageLoader = imageLoader
    }

    var body: some View {
        proofContents
            .frame(width: itemSize, height: itemSize)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private extension ChallengeWeeklyProofItem {
    var proofContents: some View {
        ZStack(alignment: .topLeading) {
            ChallengeWeeklyProofImage(
                proof: proof,
                size: CGSize(width: itemSize, height: itemSize),
                imageLoader: imageLoader
            )

            HStack(spacing: 4) {
                RemoteAvatarView(
                    imageURL: profileImageURL,
                    defaultAvatar: defaultAvatar,
                    width: 30,
                    height: 30,
                    imageLoader: imageLoader
                )

                MText(
                    proof.nickname,
                    style: .c2,
                    color: .systemWhite
                )
            }
            .padding(.leading, 16)
            .padding(.top, 16)
        }
    }

    var profileImageURL: URL? {
        makeURL(from: proof.profileImageUrl)
    }

    var defaultAvatar: DefaultAvatar {
        let avatars = DefaultAvatar.allCases
        let index = Int(proof.memberId.magnitude % UInt(avatars.count))
        return avatars[index]
    }

    func makeURL(from value: String?) -> URL? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }

        if let url = URL(string: value) {
            return url
        }

        return value
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap(URL.init(string:))
    }
}
