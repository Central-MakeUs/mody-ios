//
//  ChallengeDetailGroupOptionalRowItemTitleView.swift
//  Challenge
//
//  Created by 김동준 on 8/10/26.
//

import DesignSystem
import SwiftUI

struct ChallengeDetailGroupOptionalRowItemTitleView: View {
    private let remainingDays: Int?
    private let title: String?

    init(
        remainingDays: Int?,
        title: String?
    ) {
        self.remainingDays = remainingDays
        self.title = title
    }

    var body: some View {
        HStack(spacing: 8) {
            remainingDaysContent
            titleContent
            Spacer()

            Image.icRightArrow
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(Color.gray4)
                .frame(width: 24, height: 24)
        }
    }
}

private extension ChallengeDetailGroupOptionalRowItemTitleView {
    @ViewBuilder
    var remainingDaysContent: some View {
        if let remainingDays {
            MText(
                "D-\(remainingDays)",
                style: .c2,
                color: .systemWhite
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.gray9)
            .clipShape(Capsule())
        } else {
            SkeletonView(width: 41, height: 24)
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    var titleContent: some View {
        if let title {
            MText(
                title,
                style: .b3,
                color: .gray10,
                alignment: .leading
            )
        } else {
            SkeletonView(width: 160, height: 25)
        }
    }
}
