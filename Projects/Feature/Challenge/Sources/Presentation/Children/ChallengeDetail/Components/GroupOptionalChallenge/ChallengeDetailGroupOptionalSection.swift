//
//  ChallengeDetailGroupOptionalSection.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import DesignSystem
import CoreModyImageInterface
import SwiftUI

struct ChallengeDetailGroupOptionalSection: View {
    private let challengeList: [CurrentWeeklyChallenge]?
    private let imageLoader: RemoteImageLoading

    init(
        challengeList: [CurrentWeeklyChallenge]?,
        imageLoader: RemoteImageLoading
    ) {
        self.challengeList = challengeList
        self.imageLoader = imageLoader
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ChallengeDetailGroupOptionalTitleSection()
            challengeListSection
        }
        .greedyWidth(.leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(Color.gray00)
    }
}

private extension ChallengeDetailGroupOptionalSection {
    var challengeListSection: some View {
        VStack(spacing: 8) {
            if let challengeList {
                ForEach(challengeList, id: \.groupChallengeId) { challenge in
                    ChallengeDetailGroupOptionalRowItem(
                        challenge: challenge,
                        imageLoader: imageLoader
                    )
                }
            } else {
                ForEach(0..<4, id: \.self) { _ in
                    ChallengeDetailGroupOptionalRowItem(
                        challenge: nil,
                        imageLoader: imageLoader
                    )
                }
            }
        }
        .greedyWidth(.leading)
        .background(Color.systemWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
