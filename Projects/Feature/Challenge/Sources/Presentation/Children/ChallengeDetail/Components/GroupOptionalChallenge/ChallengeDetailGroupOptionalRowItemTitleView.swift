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
    private let isComplete: Bool

    init(
        remainingDays: Int?,
        title: String?,
        isComplete: Bool
    ) {
        self.remainingDays = remainingDays
        self.title = title
        self.isComplete = isComplete
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
            chipView(
                isComplete: isComplete,
                remainingDays: remainingDays
            )
        } else {
            SkeletonView(width: 41, height: 24)
                .clipShape(Capsule())
        }
    }
    
    func chipView(isComplete: Bool, remainingDays: Int) -> some View {
        let textColor: Color = isComplete ? Color.gray10 : Color.systemWhite
        let backgroundColor: Color = isComplete ? Color.main : Color.gray9
        
        return MText(
            chipTitle(isComplete: isComplete, remainingDays: remainingDays),
            style: .c2,
            color: textColor
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(backgroundColor)
        .clipShape(Capsule())
    }

    func chipTitle(isComplete: Bool, remainingDays: Int) -> String {
        if isComplete { return "완료" }
        if remainingDays == 0 { return "D-Day" }
        return "D-\(remainingDays)"
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
