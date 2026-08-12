//
//  ChallengeWeeklyDetailFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

import Base
import ChallengeInterface
import CommonDomain
import ComposableArchitecture
import CoreAuthInterface

@Reducer
public struct ChallengeWeeklyDetailFeature {
    private let authUseCase: AuthUseCaseProtocol
    private let challengeUseCase: ChallengeUseCase
    private let router: @MainActor (ChallengeWeeklyDetailRoute) -> Void

    public init(
        authUseCase: AuthUseCaseProtocol,
        challengeUseCase: ChallengeUseCase,
        router: @escaping @MainActor (ChallengeWeeklyDetailRoute) -> Void
    ) {
        self.authUseCase = authUseCase
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
        var myMemberId: Int?
        let groupId: Int
        let groupChallengeId: Int

        public init(groupId: Int, groupChallengeId: Int) {
            self.groupId = groupId
            self.groupChallengeId = groupChallengeId
        }
    }

    public enum Action {
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case backButtonTapped
        case onAppear
        case myMemberIdFetched(Int)
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
                guard state.myMemberId == nil else {
                    return .none
                }

                state.isLoading = true
                return .run { send in
                    await send(fetchMyMemberId())
                }
            case let .myMemberIdFetched(memberId):
                state.isLoading = false
                state.myMemberId = memberId
                return .none
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            }
        }
    }
}

private extension ChallengeWeeklyDetailFeature {
    func fetchMyMemberId() async -> Action {
        do {
            let userInfo = try await authUseCase.getUserInfo(needUpdateKeyChain: false)
            return .myMemberIdFetched(userInfo.memberId)
        } catch {
            return .showAlert(.error(error as? NetworkError ?? .unknown))
        }
    }
}
