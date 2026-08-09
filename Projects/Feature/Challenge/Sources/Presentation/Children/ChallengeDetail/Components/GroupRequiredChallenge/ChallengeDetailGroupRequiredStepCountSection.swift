//
//  ChallengeDetailGroupRequiredStepCountSection.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

import DesignSystem
import Foundation
import SwiftUI

struct ChallengeDetailGroupRequiredStepCountSection: View {
    private let status: ChallengeStepCountStatus?
    private let refreshAction: () -> Void

    init(
        status: ChallengeStepCountStatus?,
        refreshAction: @escaping () -> Void
    ) {
        self.status = status
        self.refreshAction = refreshAction
    }

    var body: some View {
        VStack(spacing: 2) {
            stepCountRow(title: "달성 걸음수", isCurrent: true)
            stepCountRow(title: "목표 걸음수", isCurrent: false)
        }
    }
}

private extension ChallengeDetailGroupRequiredStepCountSection {
    func stepCountRow(title: String, isCurrent: Bool) -> some View {
        HStack {
            MText(
                title,
                style: .c2,
                color: .gray8,
                alignment: .leading
            )
            .greedyWidth(.leading)

            stepCountContent(isCurrent: isCurrent)
        }
        .overlay(alignment: .trailing) {
            if isCurrent {
                Button {
                    refreshAction()
                } label: {
                    Image.icRefresh
                        .resizable()
                        .frame(20, 20)
                        .offset(x: 20)
                }
            }
        }
        .padding(.leading, 44)
        .padding(.trailing, 48)
    }

    @ViewBuilder
    func stepCountContent(isCurrent: Bool) -> some View {
        if let status {
            if isCurrent {
                currentStepCountText(status.currentStepCount)
            } else {
                targetStepCountText(status.targetStepCount)
            }
        } else {
            SkeletonView(
                width: isCurrent ? 69 : 59,
                height: isCurrent ? 22 : 20
            )
        }
    }

    func currentStepCountText(_ stepCount: Int) -> some View {
        (
            Text(stepCount.formatted())
                .font(ModyTypography.b5.token.swiftUIFont)
            + Text("보")
                .font(ModyTypography.c1.token.swiftUIFont)
        )
        .foregroundStyle(Color.main0)
    }

    func targetStepCountText(_ stepCount: Int) -> some View {
        (
            Text(stepCount.formatted())
                .font(ModyTypography.c1.token.swiftUIFont)
            + Text("보")
                .font(ModyTypography.c3.token.swiftUIFont)
        )
        .foregroundStyle(Color.gray10)
    }
}
