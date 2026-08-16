//
//  OnBoardingAgreementView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import SwiftUI
import DesignSystem

struct OnBoardingAgreementView: View {
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
        ScrollView {
            VStack(spacing: 0) {
                OnBoardingAgreementHeader()

                OnBoardingAgreementList(
                    isAllAccepted: isAllAccepted,
                    isPrivacyPolicyAccepted: isPrivacyPolicyAccepted,
                    isTermsOfServiceAccepted: isTermsOfServiceAccepted,
                    onAllAgreementTapped: onAllAgreementTapped,
                    onPrivacyPolicyAgreementTapped: onPrivacyPolicyAgreementTapped,
                    onTermsOfServiceAgreementTapped: onTermsOfServiceAgreementTapped,
                    onPrivacyPolicyDetailTapped: onPrivacyPolicyDetailTapped,
                    onTermsOfServiceDetailTapped: onTermsOfServiceDetailTapped
                )
                .padding(.top, 36)
            }
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.systemWhite)
    }
}
