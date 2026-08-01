//
//  ChallengeView.swift
//  Challenge
//
//  Created by 김동준 on 6/30/26
//

import SwiftUI
import ComposableArchitecture

public struct ChallengeView: View {
    @Bindable private var store: StoreOf<ChallengeFeature>

    public init(store: StoreOf<ChallengeFeature>) {
        self.store = store
    }

    public var body: some View {
        challengeBody
    }
}

private extension ChallengeView {
    var challengeBody: some View {
        VStack(spacing: 0) {
            ChallengeTabBar(selection: $store.selectedTab)

            TabView(selection: $store.selectedTab) {
                ChallengeStreakView(
                    store: store.scope(state: \.challengeStreak, action: \.challengeStreak)
                )
                .tag(ChallengeFeature.State.Tab.streak)

                ChallengeDetailView(
                    store: store.scope(state: \.challengeDetail, action: \.challengeDetail)
                )
                .tag(ChallengeFeature.State.Tab.challenge)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}
