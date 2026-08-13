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
        var weeklyChallengeDetail: WeeklyChallengeDetail?
        var weeklyChallengeImageInfos: [WeeklyChallengeImageInfo]?
        let groupId: Int
        let challengeId: Int
        let groupChallengeId: Int

        public init(groupId: Int, challengeId: Int, groupChallengeId: Int) {
            self.groupId = groupId
            self.challengeId = challengeId
            self.groupChallengeId = groupChallengeId
        }
    }

    public enum Action {
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case backButtonTapped
        case onAppear
        case initialDataFetched(
            memberId: Int,
            detail: WeeklyChallengeDetail,
            imageInfos: [WeeklyChallengeImageInfo]
        )
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
                guard state.myMemberId == nil,
                      state.weeklyChallengeDetail == nil,
                      state.weeklyChallengeImageInfos == nil else {
                    return .none
                }

                state.isLoading = true
                let groupId = state.groupId
                let challengeId = state.challengeId
                let groupChallengeId = state.groupChallengeId

                return .run { send in
                    do {
                        try await fetchInitialData(
                            send: send,
                            groupId: groupId,
                            challengeId: challengeId,
                            groupChallengeId: groupChallengeId
                        )
                    } catch {
                        await send(.showAlert(.error(error as? NetworkError ?? .unknown)))
                    }
                }
            case let .initialDataFetched(memberId, detail, imageInfos):
                state.isLoading = false
                state.myMemberId = memberId
                state.weeklyChallengeDetail = detail
                state.weeklyChallengeImageInfos = imageInfos
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
    func fetchInitialData(
        send: Send<Action>,
        groupId: Int,
        challengeId: Int,
        groupChallengeId: Int
    ) async throws {
        var memberId: Int?
        var detail: WeeklyChallengeDetail?
        var imageInfos: [WeeklyChallengeImageInfo]?

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { [authUseCase] in
                let userInfo = try await authUseCase.getUserInfo(needUpdateKeyChain: false)
                memberId = userInfo.memberId
            }
            group.addTask { [challengeUseCase] in
                detail = try await challengeUseCase.fetchWeeklyChallengeDetail(
                    challengeId: challengeId
                )
            }
            group.addTask { [challengeUseCase] in
                imageInfos = try await challengeUseCase.fetchWeeklyChallengeProofs(
                    groupId: groupId,
                    groupChallengeId: groupChallengeId
                )
            }

            do {
                for try await _ in group {}
            } catch {
                group.cancelAll()
                throw error
            }

            guard let memberId,
                  let detail,
                  let imageInfos else {
                throw NetworkError.invalidResponse
            }

            await send(.initialDataFetched(
                memberId: memberId,
                detail: detail,
                imageInfos: imageInfos
            ))
        }
    }
}
