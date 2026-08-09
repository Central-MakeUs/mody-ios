//
//  ChallengeView.swift
//  Challenge
//
//  Created by 김동준 on 6/30/26
//

import SwiftUI
import ComposableArchitecture
import CoreModyImageInterface

public struct ChallengeView: View {
    @Bindable private var store: StoreOf<ChallengeFeature>
    private let imageLoader: RemoteImageLoading

    public init(
        store: StoreOf<ChallengeFeature>,
        imageLoader: RemoteImageLoading
    ) {
        self.store = store
        self.imageLoader = imageLoader
    }

    public var body: some View {
        challengeBody
            .onDisappear { store.send(.onDisappear) }
    }
}

private extension ChallengeView {
    var challengeBody: some View {
        VStack(spacing: 0) {
            ChallengeTabBar(selection: $store.selectedTab)

            TabView(selection: $store.selectedTab) {
                ChallengeStreakView(
                    store: store.scope(state: \.challengeStreak, action: \.challengeStreak),
                    imageLoader: imageLoader
                )
                .tag(ChallengeFeature.State.Tab.streak)

                ChallengeDetailView(
                    store: store.scope(state: \.challengeDetail, action: \.challengeDetail),
                    imageLoader: imageLoader
                )
                .tag(ChallengeFeature.State.Tab.challenge)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}
