//
//  ChallengeFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import ComposableArchitecture
import ChallengeInterface
import CommonDomain
import CoreHealthInterface

@Reducer
public struct ChallengeFeature {
    private let challengeUseCase: ChallengeUseCase
    private let healthUseCase: HealthUseCaseProtocol
    private let router: @MainActor (ChallengeRoute) -> Void
    private let output: @MainActor (ChallengeOutput) -> Void

    public init(
        challengeUseCase: ChallengeUseCase,
        healthUseCase: HealthUseCaseProtocol,
        router: @escaping @MainActor (ChallengeRoute) -> Void,
        output: @escaping @MainActor (ChallengeOutput) -> Void
    ) {
        self.challengeUseCase = challengeUseCase
        self.healthUseCase = healthUseCase
        self.router = router
        self.output = output
    }

    @ObservableState
    public struct State: Equatable {
        public enum Tab: String, CaseIterable, Hashable {
            case streak = "연속 기록"
            case challenge = "챌린지"
        }

        var selectedTab: Tab = .streak
        var selectedGroup: GroupModel?
        var challengeStreak = ChallengeStreakFeature.State()
        var challengeDetail = ChallengeDetailFeature.State()

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case input(ChallengeInput)
        case onDisappear
        case challengeStreak(ChallengeStreakFeature.Action)
        case challengeDetail(ChallengeDetailFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onDisappear:
                return .send(.challengeDetail(.onDisappear))
            case let .input(.selectedGroupUpdated(group)):
                state.selectedGroup = group
                return .merge(
                    .send(.challengeStreak(.setSelectedGroup(group))),
                    .send(.challengeDetail(.setSelectedGroup(group)))
                )
            case .input(.recordUpdated):
                return .send(.challengeStreak(.refreshChallengeSummary))
            case .challengeStreak(let streakAction):
                return handleStreakAction(&state, streakAction)
            case .challengeDetail(let detailAction):
                return handleDetailAction(detailAction)
            case .binding:
                return .none
            }
        }

        Scope(state: \.challengeStreak, action: \.challengeStreak) {
            ChallengeStreakFeature(challengeUseCase: challengeUseCase)
        }

        Scope(state: \.challengeDetail, action: \.challengeDetail) {
            ChallengeDetailFeature(
                challengeUseCase: challengeUseCase,
                healthUseCase: healthUseCase
            )
        }
    }
}

private extension ChallengeFeature {
    func handleStreakAction(
        _ state: inout State,
        _ action: ChallengeStreakFeature.Action
    ) -> Effect<Action> {
        switch action {
        case .nudgeStarted:
            return .run { [output] _ in
                await output(.nudgeStarted)
            }
        case .nudgeCompleted(let nickname):
            return .run { [output] _ in
                await output(.nudgeSucceeded(nickname: nickname))
            }
        case .showAlert(let error):
            return .run { [output] _ in
                await output(.showAlert(error))
            }
        default:
            return .none
        }
    }
}

private extension ChallengeFeature {
    func handleDetailAction(_ action: ChallengeDetailFeature.Action) -> Effect<Action> {
        switch action {
        case .showAlert(let error):
            return .run { [output] _ in
                await output(.showAlert(error))
            }
        case .changeChallengeButtonTapped:
            return .run { [router] _ in
                await router(.routeToChallengeChange)
            }
        default:
            return .none
        }
    }
}
