//
//  ChallengeStreakNudgeRow.swift
//  Challenge
//
//  Created by 김동준 on 8/3/26.
//

import Base
import CommonDomain
import CoreModyImageInterface
import DesignSystem
import Foundation
import SwiftUI

struct ChallengeStreakNudgeRow: View {
    private let nickname: String?
    private let profileImageURL: String?
    private let recordedToday: Bool?
    private let imageLoader: RemoteImageLoading
    private let onNudgeButtonTapped: () -> Void

    init(
        nickname: String?,
        profileImageURL: String?,
        recordedToday: Bool?,
        imageLoader: RemoteImageLoading,
        onNudgeButtonTapped: @escaping () -> Void
    ) {
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.recordedToday = recordedToday
        self.imageLoader = imageLoader
        self.onNudgeButtonTapped = onNudgeButtonTapped
    }

    var body: some View {
        HStack(spacing: 12) {
            avatar

            memberInfo
                .greedyWidth(.leading)

            actionButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 18)
    }
}

private extension ChallengeStreakNudgeRow {
    @ViewBuilder
    var avatar: some View {
        if recordedToday != nil {
            RemoteAvatarView(
                imageURL: resolvedProfileImageURL,
                defaultAvatar: .smileLight,
                width: 40,
                height: 40,
                imageLoader: imageLoader
            )
        } else {
            SkeletonView(width: 40, height: 40)
                .clipShape(Circle())
        }
    }

    var resolvedProfileImageURL: URL? {
        guard let profileImageURL else { return nil }

        let trimmedURLString = profileImageURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURLString.isEmpty else { return nil }

        return URL(string: trimmedURLString)
    }

    @ViewBuilder
    var memberInfo: some View {
        if let nickname, let recordedToday {
            VStack(alignment: .leading, spacing: 0) {
                MText(
                    nickname,
                    style: .b6,
                    color: .gray10,
                    alignment: .leading
                )

                MText(
                    recordedToday
                        ? "오늘 기록을 완료했어요."
                        : "연속기록을 위해 불러주세요!",
                    style: .c2,
                    color: .gray6,
                    alignment: .leading
                )
            }
        } else {
            SkeletonView(width: 132, height: 42)
        }
    }

    @ViewBuilder
    var actionButton: some View {
        if let recordedToday {
            if recordedToday {
                completedButton
            } else {
                nudgeButton
            }
        } else {
            SkeletonView(width: 88, height: 34)
        }
    }

    var nudgeButton: some View {
        Button(action: onNudgeButtonTapped) {
            HStack(spacing: 2) {
                Image.icFinger
                    .resizable()
                    .frame(width: 20, height: 20)

                MText(
                    "콕 찌르기",
                    style: .c1,
                    color: .gray10
                )
            }
            .vPadding(7)
            .hPadding(8)
            .background(Color.main)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    var completedButton: some View {
        Button(action: onNudgeButtonTapped) {
            MText(
                "기록 완료",
                style: .c1,
                color: .systemWhite
            )
            .vPadding(7)
            .hPadding(18)
            .background(Color.gray3)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(true)
    }
}
