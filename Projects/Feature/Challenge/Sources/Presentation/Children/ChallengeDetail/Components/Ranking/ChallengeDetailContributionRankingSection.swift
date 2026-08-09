//
//  ChallengeDetailContributionRankingSection.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import CoreModyImageInterface
import DesignSystem
import SwiftUI

struct ChallengeDetailContributionRankingSection: View {
    private let rankings: [ChallengeStepRanking]?
    private let imageLoader: RemoteImageLoading

    init(
        rankings: [ChallengeStepRanking]?,
        imageLoader: RemoteImageLoading
    ) {
        self.rankings = rankings
        self.imageLoader = imageLoader
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            titleText
            rankingContent
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
        .background(Color.systemWhite)
    }
    
    private var titleText: some View {
        MText(
            "현재 기여도 순위",
            style: .b3,
            color: .gray10,
            alignment: .leading
        )
    }
}

private extension ChallengeDetailContributionRankingSection {
    @ViewBuilder
    var rankingContent: some View {
        if let rankings {
            loadedRankingContent(rankings)
        } else {
            loadingRankingContent
        }
    }

    func loadedRankingContent(_ rankings: [ChallengeStepRanking]) -> some View {
        VStack(spacing: 36) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(rankings.prefix(3)), id: \.memberId) { ranking in
                    ChallengeDetailContributionRankingItem(
                        ranking: ranking,
                        layout: .podium,
                        imageLoader: imageLoader
                    )
                    .greedyWidth()
                }
            }

            if rankings.count > 3 {
                VStack(spacing: 20) {
                    ForEach(Array(rankings.dropFirst(3)), id: \.memberId) { ranking in
                        ChallengeDetailContributionRankingItem(
                            ranking: ranking,
                            layout: .row,
                            imageLoader: imageLoader
                        )
                    }
                }
            }
        }
    }
}

private extension ChallengeDetailContributionRankingSection {
    var loadingRankingContent: some View {
        VStack(spacing: 36) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<3, id: \.self) { _ in
                    ChallengeDetailContributionRankingItem(
                        ranking: nil,
                        layout: .podium,
                        imageLoader: imageLoader
                    )
                    .greedyWidth()
                }
            }

            VStack(spacing: 20) {
                ForEach(0..<2, id: \.self) { _ in
                    ChallengeDetailContributionRankingItem(
                        ranking: nil,
                        layout: .row,
                        imageLoader: imageLoader
                    )
                }
            }
        }
    }
}
