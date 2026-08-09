//  ChallengeChangeRowItem.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

import DesignSystem
import Foundation
import SwiftUI

struct ChallengeChangeRowItem: View {
    private let challenge: ChangableWalkChallengeModel
    private let onTap: () -> Void

    init(
        challenge: ChangableWalkChallengeModel,
        onTap: @escaping () -> Void
    ) {
        self.challenge = challenge
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                challengeImage(challenge.targetStepCount)
                descriptionView
                Spacer()

                if challenge.completed {
                    completedChip
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(challenge.selected ? Color.main4 : .gray1)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        challenge.selected ? Color.main : .clear,
                        lineWidth: 2
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(challenge.completed || challenge.selected)
    }
}

private extension ChallengeChangeRowItem {
    @ViewBuilder
    func challengeImage(_ targetStepCount: Int) -> some View {
        if let image = walkChallengeImage(for: targetStepCount) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
        } else {
            Circle()
                .fill(Color.systemBlack)
                .frame(width: 60, height: 60)
        }
    }
    
    func walkChallengeImage(for targetStepCount: Int) -> Image? {
        switch targetStepCount {
        case 150_000:
            return .imgWalkFifteen
        case 200_000:
            return .imgWalkTwenty
        case 300_000:
            return .imgWalkThrity
        case 400_000:
            return .imgWalkFourty
        case 500_000:
            return .imgWalkFifty
        case 700_000:
            return .imgWalkSeventy
        default:
            return nil
        }
    }
}

private extension ChallengeChangeRowItem {
    var descriptionView: some View {
        VStack(alignment: .leading, spacing: 6) {
            MText(
                title,
                style: .b6,
                color: .gray10,
                alignment: .leading
            )

            MText(
                summary,
                style: .c2,
                color: .gray8,
                alignment: .leading
            )
        }
    }
}

private extension ChallengeChangeRowItem {
    var completedChip: some View {
        MText(
            "완료",
            style: .c2,
            color: .gray10
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Color.main)
        .clipShape(Capsule())
    }

    var title: String {
        "\(challenge.departure.rawValue)에서 \(challenge.destination.rawValue)까지 걸어가기"
    }

    var summary: String {
        let distance = challenge.distanceKm
        let stepCount = challenge.targetStepCount / 10_000
        return "\(distance)km / \(stepCount)만보"
    }
}
