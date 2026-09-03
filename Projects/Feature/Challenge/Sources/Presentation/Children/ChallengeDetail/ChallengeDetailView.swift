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
        GeometryReader { proxy in
            detailBody(deviceWidth: proxy.size.width)
        }
        .background(Color.gray00)
        .onAppear { store.send(.onAppear) }
    }
}

private extension ChallengeDetailView {
    @ViewBuilder
    func detailBody(deviceWidth: CGFloat) -> some View {
        switch store.contentState {
        case .loading, .content:
            detailContent(deviceWidth: deviceWidth)
        case .empty:
            ChallengeEmptyView(isStreakEmpty: false)
                .greedyFrame()
        }
    }

    func detailContent(deviceWidth: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ChallengeDetailGroupRequiredSection(
                    status: groupRequiredStatus,
                    groupName: store.selectedGroup?.name,
                    deviceWidth: deviceWidth,
                    changeAction: { store.send(.changeChallengeButtonTapped) },
                    refreshAction: { store.send(.refreshStepButtonTapped) }
                )

                ChallengeDetailContributionRankingSection(
                    rankings: store.rankings,
                    imageLoader: imageLoader
                )

                if store.currentWeeklyChallengeList?.isEmpty != true {
                    ChallengeDetailGroupOptionalSection(
                        challengeList: store.currentWeeklyChallengeList,
                        imageLoader: imageLoader,
                        onChallengeTap: { challengeId, groupChallengeId in
                            store.send(.weeklyChallengeTapped(
                                challengeId: challengeId,
                                groupChallengeId: groupChallengeId
                            ))
                        }
                    )
                }
            }
        }
        .scrollIndicators(.visible)
    }

    var groupRequiredStatus: ChallengeStepCountStatus? {
        guard store.rankings?.isEmpty == false else { return nil }
        return store.stepCountStatus
    }
}
