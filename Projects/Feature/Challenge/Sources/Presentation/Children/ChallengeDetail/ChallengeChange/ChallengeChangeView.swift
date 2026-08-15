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
            .onAppear { store.send(.onAppear) }
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
            VStack(alignment: .leading, spacing: 0) {
                MText(
                    "다른 챌린지를 선택해주세요.",
                    style: .b3,
                    color: .gray10,
                    alignment: .leading
                )

                LazyVStack(spacing: 8) {
                    ForEach(store.changableChallengeList, id: \.challengeId) { challenge in
                        ChallengeChangeRowItem(
                            challenge: challenge,
                            onTap: {
                                store.send(.challengeCardTapped(challengeId: challenge.challengeId))
                            }
                        )
                    }
                }
                .padding(.top, 24)
            }
            .padding(24)
        }
        .scrollIndicators(.visible)
    }
}

private extension ChallengeChangeView {
    @ViewBuilder
    var alertView: some View {
        if let alertCase = store.alertCase {
            switch alertCase {
            case .changeConfirmation(let id):
                MAlertContentView(
                    title: "정말 챌린지를 변경하시겠어요?",
                    contents: "지금까지 걸었던 기록이 전부 사라져요!",
                    leadingButton: MAlertButton("취소", style: .gray) {
                        store.send(.alertAction(.dismiss))
                    },
                    trailingButton: MAlertButton("변경하기") {
                        store.send(.challengeChangeConfirmationTapped(id))
                    }
                )
            case let .error(networkError):
                CommonErrorAlertView(networkError) {
                    store.send(.alertAction(.dismiss))
                }
            }
        }
    }
}
