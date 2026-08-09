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
        var changableChallengeList: [ChangableWalkChallengeModel] = []
        let groupId: Int

        public init(groupId: Int) {
            self.groupId = groupId
        }
    }

    public enum Action {
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case backButtonTapped
        case onAppear
        case changableChallengeListFetched([ChangableWalkChallengeModel])
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
            case .onAppear:
                state.isLoading = true
                let groupId = state.groupId
                return .run { send in
                    await send(fetchChangableChallengeList(groupId: groupId))
                }
            case let .changableChallengeListFetched(challengeList):
                state.isLoading = false
                state.changableChallengeList = challengeList
                return .none
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            }
        }
    }
}

private extension ChallengeChangeFeature {
    func fetchChangableChallengeList(groupId: Int) async -> Action {
        do {
            let challengeList = try await challengeUseCase.fetchChangableChallengeList(
                groupId: groupId
            )
            return .changableChallengeListFetched(challengeList)
        } catch {
            return .showAlert(.error(error as? NetworkError ?? .unknown))
        }
    }
}
