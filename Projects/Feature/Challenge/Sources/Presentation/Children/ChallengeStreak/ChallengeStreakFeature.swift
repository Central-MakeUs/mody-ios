//
//  ChallengeStreakFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import ComposableArchitecture
import CommonDomain

@Reducer
public struct ChallengeStreakFeature {
    private let challengeUseCase: ChallengeUseCase

    @ObservableState
    public struct State: Equatable {
        enum CancelID { case challengeSummary }

        var selectedGroup: GroupModel?
        var summary: ChallengeSummary?

        public init() {}
    }

    public enum Action {
        case setSelectedGroup(GroupModel?)
        case onAppear
        case refreshChallengeSummary
        case fetchChallengeSummary
        case challengeSummaryFetched(groupID: Int, ChallengeSummary?)
        case showAlert(NetworkError)
    }

    public init(challengeUseCase: ChallengeUseCase) {
        self.challengeUseCase = challengeUseCase
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchChallengeSummary)
            case .refreshChallengeSummary:
                state.summary = nil
                return .send(.fetchChallengeSummary)
            case let .setSelectedGroup(group):
                state.selectedGroup = group
                state.summary = nil

                guard group != nil else {
                    return .cancel(id: State.CancelID.challengeSummary)
                }

                return .send(.onAppear)
            case .fetchChallengeSummary:
                guard let groupID = state.selectedGroup?.groupId,
                      state.summary == nil else {
                    return .none
                }

                return .run { send in
                    await send(fetchChallengeSummary(groupID: groupID))
                }
                .cancellable(id: State.CancelID.challengeSummary, cancelInFlight: true)
            case let .challengeSummaryFetched(groupID, summary):
                guard state.selectedGroup?.groupId == groupID,
                      let summary = summary else {
                    return .none
                }

                state.summary = summary
                return .none
            case .showAlert:
                return .none
            }
        }
    }
}

private extension ChallengeStreakFeature {
    func fetchChallengeSummary(groupID: Int) async -> Action {
        do {
            let summary = try await challengeUseCase.fetchChallengeSummary(groupId: groupID)
            return .challengeSummaryFetched(groupID: groupID, summary)
        } catch {
            return .showAlert(error as? NetworkError ?? .unknown)
        }
    }
}
