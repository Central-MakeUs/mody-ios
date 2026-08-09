//
//  ChallengeChangeFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

import Base
import ChallengeInterface
import CommonDomain
import ComposableArchitecture

@Reducer
public struct ChallengeChangeFeature {
    private let challengeUseCase: ChallengeUseCase
    private let router: @MainActor (ChallengeChangeRoute) -> Void

    public init(
        challengeUseCase: ChallengeUseCase,
        router: @escaping @MainActor (ChallengeChangeRoute) -> Void
    ) {
        self.challengeUseCase = challengeUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public enum AlertCase: Equatable {
            case error(NetworkError)
        }

        var isLoading = false
        var alertCase: AlertCase?
        var alertState = AlertFeature.State()

        public init() {}
    }

    public enum Action {
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case backButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.alertState, action: \.alertAction) {
            AlertFeature()
        }

        Reduce { state, action in
            switch action {
            case .alertAction(.dismiss):
                state.alertCase = nil
                return .none
            case .alertAction:
                return .none
            case let .showAlert(alertCase):
                state.isLoading = false
                state.alertCase = alertCase
                return .send(.alertAction(.present))
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            }
        }
    }
}
