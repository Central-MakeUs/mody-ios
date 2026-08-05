//
//  ChallengeStreakNudgeSection.swift
//  Challenge
//
//  Created by 김동준 on 8/3/26.
//

import CoreModyImageInterface
import DesignSystem
import SwiftUI

struct ChallengeStreakNudgeSection: View {
    private let nudgeInfos: [ChallengeNudgeInfo]?
    private let imageLoader: RemoteImageLoading
    private let onNudgeButtonTapped: (Int) -> Void

    init(
        nudgeInfos: [ChallengeNudgeInfo]?,
        imageLoader: RemoteImageLoading,
        onNudgeButtonTapped: @escaping (Int) -> Void
    ) {
        self.nudgeInfos = nudgeInfos
        self.imageLoader = imageLoader
        self.onNudgeButtonTapped = onNudgeButtonTapped
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle

            VStack(spacing: 0) {
                if let nudgeInfos {
                    ForEach(nudgeInfos, id: \.memberId) { info in
                        ChallengeStreakNudgeRow(
                            nickname: info.nickname,
                            profileImageURL: info.profileImageUrl,
                            recordedToday: info.recordedToday,
                            imageLoader: imageLoader
                        ) {
                            onNudgeButtonTapped(info.memberId)
                        }
                    }
                } else {
                    ForEach(0..<4, id: \.self) { _ in
                        ChallengeStreakNudgeRow(
                            nickname: nil,
                            profileImageURL: nil,
                            recordedToday: nil,
                            imageLoader: imageLoader,
                            onNudgeButtonTapped: {}
                        )
                    }
                }
            }
            .background(Color.systemWhite)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .vPadding(32)
        .padding(.horizontal, 24)
    }
}

private extension ChallengeStreakNudgeSection {
    var sectionTitle: some View {
        HStack(spacing: 4) {
            Image.icAward
                .resizable()
                .frame(width: 24, height: 24)

            MText(
                "버디들과 신기록 도전",
                style: .b3,
                color: .gray10,
                alignment: .leading
            )
        }
        .greedyWidth(.leading)
    }
}
