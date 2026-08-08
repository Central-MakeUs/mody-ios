//
//  ChallengeDetailView.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct ChallengeDetailView: View {
    private let store: StoreOf<ChallengeDetailFeature>

    public init(store: StoreOf<ChallengeDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        detailBody
            .background(Color.gray00)
            .onAppear { store.send(.onAppear) }
    }
}

private extension ChallengeDetailView {
    @ViewBuilder
    var detailBody: some View {
        switch store.contentState {
        case .loading, .content:
            Text("챌린지")
        case .empty:
            ChallengeEmptyView(isStreakEmpty: false)
                .greedyFrame()
        }
    }
}
