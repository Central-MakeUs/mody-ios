//
//  OnBoardingAgreementList.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import DesignSystem
import SwiftUI

struct OnBoardingAgreementList: View {
    private let isAllAccepted: Bool
    private let isPrivacyPolicyAccepted: Bool
    private let isTermsOfServiceAccepted: Bool
    private let onAllAgreementTapped: () -> Void
    private let onPrivacyPolicyAgreementTapped: () -> Void
    private let onTermsOfServiceAgreementTapped: () -> Void
    private let onPrivacyPolicyDetailTapped: () -> Void
    private let onTermsOfServiceDetailTapped: () -> Void
    
    init(
        isAllAccepted: Bool,
        isPrivacyPolicyAccepted: Bool,
        isTermsOfServiceAccepted: Bool,
        onAllAgreementTapped: @escaping () -> Void,
        onPrivacyPolicyAgreementTapped: @escaping () -> Void,
        onTermsOfServiceAgreementTapped: @escaping () -> Void,
        onPrivacyPolicyDetailTapped: @escaping () -> Void,
        onTermsOfServiceDetailTapped: @escaping () -> Void
    ) {
        self.isAllAccepted = isAllAccepted
        self.isPrivacyPolicyAccepted = isPrivacyPolicyAccepted
        self.isTermsOfServiceAccepted = isTermsOfServiceAccepted
        self.onAllAgreementTapped = onAllAgreementTapped
        self.onPrivacyPolicyAgreementTapped = onPrivacyPolicyAgreementTapped
        self.onTermsOfServiceAgreementTapped = onTermsOfServiceAgreementTapped
        self.onPrivacyPolicyDetailTapped = onPrivacyPolicyDetailTapped
        self.onTermsOfServiceDetailTapped = onTermsOfServiceDetailTapped
    }

    var body: some View {
        VStack(spacing: 0) {
            allAgreementButton

            VStack(spacing: 0) {
                OnBoardingAgreementRow(
                    title: "개인정보처리방침 (필수)",
                    isAccepted: isPrivacyPolicyAccepted,
                    onAgreementTapped: onPrivacyPolicyAgreementTapped,
                    onDetailTapped: onPrivacyPolicyDetailTapped
                )

                OnBoardingAgreementRow(
                    title: "이용약관 (필수)",
                    isAccepted: isTermsOfServiceAccepted,
                    onAgreementTapped: onTermsOfServiceAgreementTapped,
                    onDetailTapped: onTermsOfServiceDetailTapped
                )
            }
            .padding(.top, 16)
            .padding(.leading, 14)
        }
    }
}

private extension OnBoardingAgreementList {
    var allAgreementButton: some View {
        MButton(
            "전체 동의",
            style: .primary,
            horizontalPadding: 0,
            verticalPadding: 13,
            maxWidth: .infinity,
            trailingIcon: .icCheck,
            trailingIconSize: .init(width: 24, height: 24),
            trailingIconColor: isAllAccepted ? .gray10 : .gray5,
            action: onAllAgreementTapped
        )
    }
}
