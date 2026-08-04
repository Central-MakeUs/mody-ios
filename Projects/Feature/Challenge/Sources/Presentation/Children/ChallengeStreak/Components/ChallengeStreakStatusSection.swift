//
//  ChallengeStreakStatusSection.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import DesignSystem
import SwiftUI

struct ChallengeStreakStatusSection: View {
    private let allMemberRecordedDays: Int?
    private let hasStartedStreak: Bool?

    init(allMemberRecordedDays: Int?, hasStartedStreak: Bool?) {
        self.allMemberRecordedDays = allMemberRecordedDays
        self.hasStartedStreak = hasStartedStreak
    }

    var body: some View {
        HStack(spacing: 12) {
            statusContent
                .greedyWidth(.leading)

            Image.imgModyChallengeWithFlag
        }
        .padding(.top, 36)
        .padding(.horizontal, 36)
        .background(Color.systemWhite)
    }
}

private extension ChallengeStreakStatusSection {
    @ViewBuilder
    var statusContent: some View {
        if let allMemberRecordedDays, let hasStartedStreak {
            statusView(
                allMemberRecordedDays: allMemberRecordedDays,
                hasStartedStreak: hasStartedStreak
            )
        } else {
            SkeletonView(width: 178, height: 78)
        }
    }

    @ViewBuilder
    func statusView(allMemberRecordedDays: Int, hasStartedStreak: Bool) -> some View {
        if hasStartedStreak {
            VStack(alignment: .leading, spacing: 0) {
                streakDaysText(allMemberRecordedDays)

                MText(
                    allMemberRecordedDays > 0
                        ? "전원 연속 기록 완료!"
                        : "연속기록이 끊겼어요!",
                    style: .b2,
                    color: .gray9,
                    alignment: .leading
                )
            }
        } else {
            MText(
                "버디들과 연속기록을\n시작해보세요!",
                style: .b2,
                color: .gray9,
                lineLimit: 2,
                alignment: .leading
            )
        }
    }

    func streakDaysText(_ allMemberRecordedDays: Int) -> some View {
        (
            Text("\(allMemberRecordedDays)")
                .font(ModyTypography.h1.token.swiftUIFont)
            + Text("일째")
                .font(ModyTypography.h1.token.swiftUIFont)
        )
        .foregroundStyle(Color.gray9)
        .lineLimit(1)
    }
}
