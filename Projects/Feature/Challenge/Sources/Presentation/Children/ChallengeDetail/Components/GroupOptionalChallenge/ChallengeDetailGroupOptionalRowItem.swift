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

    init(
        challenge: CurrentWeeklyChallenge?,
        imageLoader: RemoteImageLoading
    ) {
        self.challenge = challenge
        self.imageLoader = imageLoader
    }

    var body: some View {
        Button {
            // TODO: Implement
        } label: {
            VStack(spacing: 20) {
                ChallengeDetailGroupOptionalRowItemTitleView(
                    remainingDays: challenge?.remainingDays,
                    title: challenge?.title
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
