//
//  ChallengeDetailGroupOptionalRowItem.swift
//  Challenge
//
//  Created by 김동준 on 8/10/26.
//

import CommonDomain
import CoreModyImageInterface
import SwiftUI

struct ChallengeDetailGroupOptionalRowItem: View {
    private let challenge: CurrentWeeklyChallenge?
    private let imageLoader: RemoteImageLoading
    private let onTap: (Int, Int) -> Void

    init(
        challenge: CurrentWeeklyChallenge?,
        imageLoader: RemoteImageLoading,
        onTap: @escaping (Int, Int) -> Void
    ) {
        self.challenge = challenge
        self.imageLoader = imageLoader
        self.onTap = onTap
    }

    var body: some View {
        Button {
            guard let challenge else { return }
            onTap(challenge.challengeId, challenge.groupChallengeId)
        } label: {
            VStack(spacing: 20) {
                ChallengeDetailGroupOptionalRowItemTitleView(
                    remainingDays: challenge?.remainingDays,
                    title: challenge?.title,
                    isComplete: challenge?.isComplete ?? false
                )
                ChallengeDetailGroupOptionalRowItemContentsView(
                    challenge: challenge,
                    imageLoader: imageLoader
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
}
