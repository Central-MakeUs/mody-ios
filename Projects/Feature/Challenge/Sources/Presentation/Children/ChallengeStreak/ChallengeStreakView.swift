//
//  ChallengeStreakView.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import SwiftUI
import ComposableArchitecture
import CoreModyImageInterface
import DesignSystem

public struct ChallengeStreakView: View {
    private let store: StoreOf<ChallengeStreakFeature>
    private let imageLoader: RemoteImageLoading

    public init(
        store: StoreOf<ChallengeStreakFeature>,
        imageLoader: RemoteImageLoading
    ) {
        self.store = store
        self.imageLoader = imageLoader
    }

    public var body: some View {
        streakBody
            .background(Color.gray00)
            .onAppear { store.send(.onAppear) }
    }
}

private extension ChallengeStreakView {
    @ViewBuilder
    var streakBody: some View {
        switch store.contentState {
        case .loading, .content:
            streakContent
        case .empty:
            ChallengeStreakEmptyView()
                .greedyFrame()
        }
    }

    var streakContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                ChallengeStreakStatusSection(
                    allMemberRecordedDays: store.summary?.allMemberRecordedDays,
                    hasStartedStreak: store.summary?.hasStartedStreak
                )

                ChallengeStreakSummarySection(
                    daysTogether: store.summary?.daysTogether,
                    monthlyExerciseMinutes: store.summary?.monthlyExerciseMinutes,
                    monthlyCompletedChallengeCount: store.summary?.monthlyCompletedChallengeCount
                )

                ChallengeStreakNudgeSection(
                    nudgeInfos: store.nudgeInfos,
                    imageLoader: imageLoader
                ) { memberID in
                    store.send(.nudgeButtonTapped(memberID: memberID))
                }
            }
        }
        .scrollIndicators(.visible)
    }
}
