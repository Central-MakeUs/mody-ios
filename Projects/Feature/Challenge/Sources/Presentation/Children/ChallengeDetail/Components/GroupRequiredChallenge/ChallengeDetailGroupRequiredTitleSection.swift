//
//  ChallengeDetailGroupRequiredTitleSection.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

import DesignSystem
import SwiftUI

struct ChallengeDetailGroupRequiredTitleSection: View {
    private let status: ChallengeStepCountStatus?
    private let groupName: String?
    private let changeAction: () -> Void

    init(
        status: ChallengeStepCountStatus?,
        groupName: String?,
        changeAction: @escaping () -> Void
    ) {
        self.status = status
        self.groupName = groupName
        self.changeAction = changeAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            requiredChallengeChip

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    titleContent
                    subtitleContent
                }.greedyWidth(.leading)
                
                changeButton
            }
        }
        .greedyWidth(.leading)
    }
}

private extension ChallengeDetailGroupRequiredTitleSection {
    var requiredChallengeChip: some View {
        MText(
            "그룹 필수 챌린지",
            style: .c1,
            color: .gray8
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.main3)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(Color.main0, lineWidth: 1)
        }
    }

    @ViewBuilder
    var titleContent: some View {
        if let status {
            MText(
                status.walkChallengeGroup.title,
                style: .h3,
                color: .gray10,
                alignment: .leading
            )
        } else {
            SkeletonView(width: 203, height: 28)
        }
    }

    @ViewBuilder
    var subtitleContent: some View {
        if status != nil && groupName != nil {
            MText(
                subtitle,
                style: .c2,
                color: .gray7,
                alignment: .leading
            )
        } else {
            SkeletonView(width: 203, height: 20)
        }
    }

    var subtitle: String {
        guard let groupName, !groupName.isEmpty else {
            return "목표까지 얼마 안 남았어요!"
        }

        return "\(groupName), 목표까지 얼마 안 남았어요!"
    }
}

private extension ChallengeDetailGroupRequiredTitleSection {
    var changeButton: some View {
        Button {
            changeAction()
        } label: {
            MText(
                "챌린지 변경",
                style: .c1,
                color: .systemWhite
            )
            .hPadding(12)
            .vPadding(7)
            .background(Color.gray9)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(status == nil)
        }
    }
}
