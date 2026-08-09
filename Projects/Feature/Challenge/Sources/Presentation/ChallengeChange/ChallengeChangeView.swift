//
//  ChallengeChangeView.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

import Base
import ComposableArchitecture
import DesignSystem
import SwiftUI

struct ChallengeChangeView: View {
    private let store: StoreOf<ChallengeChangeFeature>

    init(store: StoreOf<ChallengeChangeFeature>) {
        self.store = store
    }

    var body: some View {
        challengeChangeBody
            .background(Color.systemWhite)
            .mLoading(isPresent: store.isLoading)
            .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
                alertView
            }
    }
    
    private var challengeChangeBody: some View {
        VStack(spacing: 0) {
            navigationBar
            scrollBody
        }
    }
}

private extension ChallengeChangeView {
    var navigationBar: some View {
        MNavigationBar(
            title: "챌린지 변경",
            onBackTap: { store.send(.backButtonTapped) }
        )
    }
    
    var scrollBody: some View {
        ScrollView {
            VStack(spacing: 0) {
                
            }
        }
    }
}

private extension ChallengeChangeView {
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
