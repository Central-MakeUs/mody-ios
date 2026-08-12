//
//  ChallengeWeeklyDetailView.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

import Base
import ComposableArchitecture
import DesignSystem
import SwiftUI

struct ChallengeWeeklyDetailView: View {
    private let store: StoreOf<ChallengeWeeklyDetailFeature>

    init(store: StoreOf<ChallengeWeeklyDetailFeature>) {
        self.store = store
    }

    var body: some View {
        challengeWeeklyDetailBody
            .background(Color.systemWhite)
            .mLoading(isPresent: store.isLoading)
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
    }
}

private extension ChallengeWeeklyDetailView {
    var challengeWeeklyDetailBody: some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "주간 챌린지",
                onBackTap: { store.send(.backButtonTapped) }
            )

            Spacer()
        }
    }

    @ViewBuilder
    var alertView: some View {
        if let alertCase = store.alertCase {
            switch alertCase {
            case let .error(networkError):
                CommonErrorAlertView(networkError) {
                    store.send(.alertAction(.dismiss))
                }
            }
        }
    }
}
