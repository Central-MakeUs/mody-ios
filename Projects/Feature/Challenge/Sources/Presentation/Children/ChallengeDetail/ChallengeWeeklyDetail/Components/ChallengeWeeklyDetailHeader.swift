//
//  ChallengeWeeklyDetailHeader.swift
//  Challenge
//
//  Created by 김동준 on 8/13/26.
//

import DesignSystem
import SwiftUI

struct ChallengeWeeklyDetailHeader: View {
    private let detail: WeeklyChallengeDetail

    init(detail: WeeklyChallengeDetail) {
        self.detail = detail
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                MText(
                    detail.title,
                    style: .b3,
                    color: .gray10,
                    alignment: .leading
                )
                .greedyWidth(.leading)

                MText(
                    remainingDaysTitle(detail.remainingDays),
                    style: .c2,
                    color: .gray10
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.main)
                .clipShape(Capsule())
            }

            MText(
                detail.description,
                style: .c2,
                color: .gray8,
                alignment: .leading
            )
        }
        .padding(16)
        .background(Color.main4)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private extension ChallengeWeeklyDetailHeader {
    func remainingDaysTitle(_ remainingDays: Int) -> String {
        if remainingDays == 0 { return "D-Day" }
        return "D-\(remainingDays)"
    }
}
