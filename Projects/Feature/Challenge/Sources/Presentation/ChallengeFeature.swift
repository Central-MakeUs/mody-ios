//
//  ChallengeFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import ComposableArchitecture
import ChallengeInterface

@Reducer
public struct ChallengeFeature {
    private let challengeUseCase: ChallengeUseCase
    private let router: @MainActor (ChallengeRoute) -> Void

    public init(
        challengeUseCase: ChallengeUseCase,
        router: @escaping @MainActor (ChallengeRoute) -> Void
    ) {
        self.challengeUseCase = challengeUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public enum Tab: String, CaseIterable, Hashable {
            case streak = "연속 기록"
            case challenge = "챌린지"
        }

        var selectedTab: Tab = .streak
        var challengeStreak = ChallengeStreakFeature.State()
        var challengeDetail = ChallengeDetailFeature.State()

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case challengeStreak(ChallengeStreakFeature.Action)
        case challengeDetail(ChallengeDetailFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.challengeStreak, action: \.challengeStreak) {
            ChallengeStreakFeature()
        }

        Scope(state: \.challengeDetail, action: \.challengeDetail) {
            ChallengeDetailFeature()
        }
    }
}
