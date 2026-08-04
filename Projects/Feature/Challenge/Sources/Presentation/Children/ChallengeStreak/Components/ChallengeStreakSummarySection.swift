//
//  ChallengeStreakSummarySection.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import DesignSystem
import SwiftUI

struct ChallengeStreakSummarySection: View {
    private let daysTogether: Int?
    private let monthlyExerciseMinutes: Int?
    private let monthlyCompletedChallengeCount: Int?

    init(
        daysTogether: Int?,
        monthlyExerciseMinutes: Int?,
        monthlyCompletedChallengeCount: Int?
    ) {
        self.daysTogether = daysTogether
        self.monthlyExerciseMinutes = monthlyExerciseMinutes
        self.monthlyCompletedChallengeCount = monthlyCompletedChallengeCount
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            summaryItem(
                firstTitle: "모디 그룹과",
                secondTitle: "함께한지",
                value: daysTogether.map { "D+\($0)" },
                skeletonWidth: 58
            )

            Spacer()
            summarySeparator
            Spacer()

            summaryItem(
                firstTitle: "이번달 함께한",
                secondTitle: "운동시간",
                value: monthlyExerciseMinutes.map { String($0 / 60) },
                unit: "시간",
                skeletonWidth: 60
            )

            Spacer()
            summarySeparator
            Spacer()

            summaryItem(
                firstTitle: "이번달 함께한",
                secondTitle: "챌린지 개수",
                value: monthlyCompletedChallengeCount.map(String.init),
                unit: "개",
                skeletonWidth: 48
            )
        }
        .greedyWidth()
        .padding(.top, 28)
        .padding(.horizontal, 36)
        .padding(.bottom, 30)
        .background(Color.systemWhite)
    }
}

private extension ChallengeStreakSummarySection {
    func summaryItem(
        firstTitle: String,
        secondTitle: String,
        value: String?,
        unit: String = "",
        skeletonWidth: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            VStack(alignment: .leading, spacing: 0) {
                MText(
                    firstTitle,
                    style: .c4,
                    color: .gray6,
                    alignment: .leading
                )

                MText(
                    secondTitle,
                    style: .c1,
                    color: .gray9,
                    alignment: .leading
                )
            }

            if let value {
                summaryValue(value, unit: unit)
            } else {
                SkeletonView(width: skeletonWidth, height: 34)
            }
        }
        .greedyWidth(.leading)
    }

    func summaryValue(_ value: String, unit: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            MText(
                value,
                style: .h2,
                color: .gray9,
                alignment: .leading
            )

            if !unit.isEmpty {
                MText(
                    unit,
                    style: .b3,
                    color: .gray9,
                    alignment: .leading
                )
            }
        }
    }

    var summarySeparator: some View {
        Rectangle()
            .fill(Color.gray2)
            .frame(width: 1, height: 64)
            .greedyHeight()
            .hPadding(12)
    }
}
