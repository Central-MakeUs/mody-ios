//
//  ChallengeFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import ComposableArchitecture
import ChallengeInterface
import CommonDomain
import CoreAnalyticsInterface
import CoreHealthInterface

@Reducer
public struct ChallengeFeature {
    private let challengeUseCase: ChallengeUseCase
    private let healthUseCase: HealthUseCaseProtocol
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private let router: @MainActor (ChallengeRoute) -> Void
    private let output: @MainActor (ChallengeOutput) -> Void

    public init(
        challengeUseCase: ChallengeUseCase,
        healthUseCase: HealthUseCaseProtocol,
        analyticsUseCase: AnalyticsUseCaseProtocol,
        router: @escaping @MainActor (ChallengeRoute) -> Void,
        output: @escaping @MainActor (ChallengeOutput) -> Void
    ) {
        self.challengeUseCase = challengeUseCase
        self.healthUseCase = healthUseCase
        self.analyticsUseCase = analyticsUseCase
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
        case challengeStreak(ChallengeStreakFeature.Action)
        case challengeDetail(ChallengeDetailFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .input(.selectedGroupUpdated(group)):
                state.selectedGroup = group
                return .merge(
                    .send(.challengeStreak(.setSelectedGroup(group))),
                    .send(.challengeDetail(.setSelectedGroup(group)))
                )
            case .input(.recordUpdated):
                return .send(.challengeStreak(.refreshChallengeSummary))
            case .input(.stepChallengeChanged):
                return .send(.challengeDetail(.stepChallengeChanged))
            case .input(.weeklyChallengeProofCreated):
                return .send(.challengeDetail(.refreshCurrentWeeklyChallenge))
            case .input(.challengeDetailRequested):
                state.selectedTab = .challenge
                return .none
            case .challengeStreak(let streakAction):
                return handleStreakAction(&state, streakAction)
            case .challengeDetail(let detailAction):
                return handleDetailAction(state, detailAction)
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
        case let .nudgeCompleted(_, _, nickname):
            return .run { [output] _ in
                analyticsUseCase.log(ChallengeAnalyticsEvent.nudgeSucceeded)
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
    func handleDetailAction(
        _ state: State,
        _ action: ChallengeDetailFeature.Action
    ) -> Effect<Action> {
        switch action {
        case .refreshStepButtonTapped:
            return .run { _ in
                analyticsUseCase.log(ChallengeAnalyticsEvent.stepRefreshClicked)
            }
        case .showAlert(let error):
            return .run { [output] _ in
                await output(.showAlert(error))
            }
        case .changeChallengeButtonTapped:
            guard let groupId = state.selectedGroup?.groupId else {
                return .none
            }

            return .run { [router] _ in
                await router(.routeToChallengeChange(groupId: groupId))
            }
        case let .weeklyChallengeTapped(challengeId, groupChallengeId):
            guard let groupId = state.selectedGroup?.groupId,
                  state.challengeDetail.currentWeeklyChallengeList?.contains(
                    where: {
                        $0.challengeId == challengeId &&
                        $0.groupChallengeId == groupChallengeId
                    }
                  ) == true else {
                return .none
            }

            return .run { [router] _ in
                await router(
                    .routeToWeeklyDetail(
                        groupId: groupId,
                        challengeId: challengeId,
                        groupChallengeId: groupChallengeId
                    )
                )
            }
        default:
            return .none
        }
    }
}
