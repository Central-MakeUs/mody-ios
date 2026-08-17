//
//  ChallengeDetailContributionRankingItem.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import Base
import CommonDomain
import CoreModyImageInterface
import DesignSystem
import Foundation
import SwiftUI

struct ChallengeDetailContributionRankingItem: View {
    enum Layout {
        case podium
        case row
    }

    private let ranking: ChallengeStepRanking?
    private let layout: Layout
    private let imageLoader: RemoteImageLoading

    init(
        ranking: ChallengeStepRanking?,
        layout: Layout,
        imageLoader: RemoteImageLoading
    ) {
        self.ranking = ranking
        self.layout = layout
        self.imageLoader = imageLoader
    }

    var body: some View {
        switch layout {
        case .podium:
            podiumItem
        case .row:
            rowItem
        }
    }
}

private extension ChallengeDetailContributionRankingItem {
    var podiumItem: some View {
        VStack(spacing: 4) {
            VStack(spacing: 8) {
                rankView(skeletonWidth: 32)
                avatar(size: 44)
                nicknameView(skeletonWidth: 48)
            }

            stepCountView(skeletonWidth: 56)
        }
    }

    var rowItem: some View {
        HStack(spacing: 12) {
            rankView(skeletonWidth: 32)
            avatar(size: 36)
            nicknameView(skeletonWidth: 48)
            Spacer()
            stepCountView(skeletonWidth: 56)
        }
    }


    var profileImageURL: URL? {
        guard let ranking else { return nil }

        let trimmedURLString = ranking.profileImageUrl
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURLString.isEmpty else { return nil }

        if let url = URL(string: trimmedURLString) {
            return url
        }

        return trimmedURLString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap(URL.init(string:))
    }

    var avatarStroke: (color: Color, width: CGFloat)? {
        guard case .podium = layout,
              let ranking else {
            return nil
        }

        switch ranking.rank {
        case 1:
            return (.main, 1.4)
        case 2:
            return (.gray2, 1.2)
        default:
            return nil
        }
    }
}

private extension ChallengeDetailContributionRankingItem {
    @ViewBuilder
    func rankView(skeletonWidth: CGFloat) -> some View {
        if let ranking {
            HStack(spacing: 0) {
                if ranking.rank == 1 {
                    Image.icCrown
                        .resizable()
                        .frame(width: 20, height: 20)
                }

                MText(
                    "\(ranking.rank)등",
                    style: .b6,
                    color: .gray10
                )
            }
        } else {
            SkeletonView(width: skeletonWidth, height: 22)
        }
    }
    
    @ViewBuilder
    func avatar(size: CGFloat) -> some View {
        if ranking != nil {
            RemoteAvatarView(
                imageURL: profileImageURL,
                defaultAvatar: .smileLight,
                width: size,
                height: size,
                imageLoader: imageLoader
            )
            .overlay {
                if let avatarStroke {
                    Circle()
                        .strokeBorder(avatarStroke.color, lineWidth: avatarStroke.width)
                }
            }
        } else {
            SkeletonView(width: size, height: size)
                .clipShape(Circle())
        }
    }
    
    @ViewBuilder
    func nicknameView(skeletonWidth: CGFloat) -> some View {
        if let ranking {
            MText(
                ranking.nickname,
                style: .b6,
                color: .gray10
            )
        } else {
            SkeletonView(width: skeletonWidth, height: 22)
        }
    }
    
    @ViewBuilder
    func stepCountView(skeletonWidth: CGFloat) -> some View {
        if let ranking {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                MText(
                    ranking.stepCount.formatted(),
                    style: .b6,
                    color: .gray7
                )

                MText(
                    "보",
                    style: .c2,
                    color: .gray7
                )
            }
            .contentTransition(.numericText(value: Double(ranking.stepCount)))
        } else {
            SkeletonView(width: skeletonWidth, height: 22)
        }
    }
}
