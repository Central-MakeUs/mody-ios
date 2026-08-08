//
//  ChallengeDetailView.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import SwiftUI
import ComposableArchitecture
import CoreModyImageInterface
import DesignSystem

public struct ChallengeDetailView: View {
    private let store: StoreOf<ChallengeDetailFeature>
    private let imageLoader: RemoteImageLoading

    public init(
        store: StoreOf<ChallengeDetailFeature>,
        imageLoader: RemoteImageLoading
    ) {
        self.store = store
        self.imageLoader = imageLoader
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
            detailContent
        case .empty:
            ChallengeEmptyView(isStreakEmpty: false)
                .greedyFrame()
        }
    }

    var detailContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                ChallengeDetailGroupRequiredSection()

                ChallengeDetailContributionRankingSection(
                    rankings: store.rankings,
                    imageLoader: imageLoader
                )

                ChallengeDetailGroupOptionalSection()
            }
        }
        .scrollIndicators(.visible)
    }
}
