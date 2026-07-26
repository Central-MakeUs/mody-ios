//
//  OnBoardingAgreementDetailView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

struct OnBoardingAgreementDetailView: View {
    private let store: StoreOf<OnBoardingAgreementDetailFeature>

    init(store: StoreOf<OnBoardingAgreementDetailFeature>) {
        self.store = store
    }

    var body: some View {
        detailBody
            .background(Color.systemWhite)
            .navigationBarBackButtonHidden()
    }
    
    private var detailBody: some View {
        VStack(spacing: 0) {
            MNavigationBar(
                onBackTap: {
                    store.send(.backButtonTapped)
                }
            )

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    MText(
                        store.document.title,
                        style: .h2,
                        color: .gray10,
                        alignment: .leading
                    )

                    ForEach(Array(store.document.sections.enumerated()), id: \.offset) { _, section in
                        OnBoardingAgreementSectionView(section: section)
                    }

                    MText(
                        store.document.effectiveDateNotice,
                        style: .c2,
                        color: .gray6,
                        lineLimit: nil,
                        alignment: .leading
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
