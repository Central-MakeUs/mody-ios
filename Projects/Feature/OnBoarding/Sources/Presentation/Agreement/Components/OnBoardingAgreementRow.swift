//
//  OnBoardingAgreementRow.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import DesignSystem
import SwiftUI

struct OnBoardingAgreementRow: View {
    private let title: String
    private let isAccepted: Bool
    private let onAgreementTapped: () -> Void
    private let onDetailTapped: () -> Void
    
    init(
        title: String,
        isAccepted: Bool,
        onAgreementTapped: @escaping () -> Void,
        onDetailTapped: @escaping () -> Void
    ) {
        self.title = title
        self.isAccepted = isAccepted
        self.onAgreementTapped = onAgreementTapped
        self.onDetailTapped = onDetailTapped
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onAgreementTapped) {
                HStack(spacing: 8) {
                    Image.icCheck
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(isAccepted ? Color.main0 : Color.gray4)
                        .frame(width: 24, height: 24)

                    MText(
                        title,
                        style: .b7,
                        color: .gray7,
                        alignment: .leading
                    )

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }

            Button(action: onDetailTapped) {
                Image.icRightArrow
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray3)
                    .frame(width: 24, height: 24)
            }
        }
    }
}
