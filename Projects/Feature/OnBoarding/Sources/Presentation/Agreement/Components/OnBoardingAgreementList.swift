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
        agreementBody
    }
    
    private var agreementBody: some View {
        VStack(spacing: 0) {
            allAgreementButton
                .padding(.bottom, 24)
            
            VStack(spacing: 16) {
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
            .hPadding(14)
        }
    }
}

private extension OnBoardingAgreementList {
    var allAgreementButton: some View {
        Button {
            onAllAgreementTapped()
        } label: {
            HStack(spacing: 0) {
                Image.icCheck
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(isAllAccepted ? Color.gray10 : Color.gray3)
                
                MText(
                    "전체 동의",
                    style: .b3,
                    color: .gray10
                )
            }
            .padding(14)
            .greedyWidth(.leading)
        }
        .background(Color.main)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
