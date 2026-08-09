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
    private let output: @MainActor (ChallengeOutput) -> Void

    public init(
        challengeUseCase: ChallengeUseCase,
        router: @escaping @MainActor (ChallengeChangeRoute) -> Void,
        output: @escaping @MainActor (ChallengeOutput) -> Void
    ) {
        self.challengeUseCase = challengeUseCase
        self.router = router
        self.output = output
    }

    @ObservableState
    public struct State: Equatable {
        public enum AlertCase: Equatable {
            case changeConfirmation(challengeId: Int)
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
        case challengeCardTapped(challengeId: Int)
        case challengeChangeConfirmationTapped(Int)
        case challengeChanged
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
                state.alertState.dismissOnScrimTap = true
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
            case let .challengeCardTapped(challengeId):
                guard let challenge = state.changableChallengeList.first(
                    where: { $0.challengeId == challengeId }
                ), !challenge.completed, !challenge.selected else {
                    return .none
                }

                state.alertCase = .changeConfirmation(challengeId: challengeId)
                state.alertState.dismissOnScrimTap = false
                return .send(.alertAction(.present))
            case .challengeChangeConfirmationTapped(let id):
                guard let challenge = state.changableChallengeList.first(
                    where: { $0.challengeId == id }
                  ) else { return .send(.alertAction(.dismiss)) }

                state.isLoading = true
                let groupId = state.groupId
                return .merge(
                    .send(.alertAction(.dismiss)),
                    .run { send in
                        await send(
                            changeStepChallenge(groupId: groupId, challengeId: id)
                        )
                    }
                )
            case .challengeChanged:
                state.isLoading = false
                return .run { [output, router] _ in
                    await output(.stepChallengeChanged)
                    await router(.back)
                }
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

    func changeStepChallenge(groupId: Int, challengeId: Int) async -> Action {
        do {
            try await challengeUseCase.changeStepChallenge(
                groupId: groupId,
                challengeId: challengeId
            )
            return .challengeChanged
        } catch {
            return .showAlert(.error(error as? NetworkError ?? .unknown))
        }
    }
}
