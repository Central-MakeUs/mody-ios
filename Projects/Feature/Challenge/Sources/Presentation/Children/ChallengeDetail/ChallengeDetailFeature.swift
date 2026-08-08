//
//  ChallengeDetailFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import ComposableArchitecture
import CommonDomain

@Reducer
public struct ChallengeDetailFeature {
    private let challengeUseCase: ChallengeUseCase

    @ObservableState
    public struct State: Equatable {
        enum ContentState {
            case loading
            case empty
            case content
        }

        var selectedGroup: GroupModel?
        var rankings: [ChallengeStepRanking]?

        var contentState: ContentState {
            guard let rankings else { return .loading }
            return rankings.isEmpty ? .empty : .content
        }

        public init() {}
    }

    public enum Action {
        case setSelectedGroup(GroupModel?)
        case onAppear
        case fetchChallengeStepRankings
        case challengeStepRankingsFetched(groupID: Int, [ChallengeStepRanking])
        case showAlert(NetworkError)
    }

    public init(challengeUseCase: ChallengeUseCase) {
        self.challengeUseCase = challengeUseCase
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setSelectedGroup(group):
                state.selectedGroup = group
                state.rankings = nil

                return .send(.fetchChallengeStepRankings)
            case .onAppear:
                switch state.contentState {
                case .loading:
                    return .send(.fetchChallengeStepRankings)
                case .empty:
                    return .none
                case .content:
                    // TODO: 이후 로직 추가
                    return .none
                }
            case .fetchChallengeStepRankings:
                guard let groupID = state.selectedGroup?.groupId,
                      state.rankings == nil else {
                    return .none
                }

                return .run { send in
                    await send(fetchChallengeStepRankings(groupID: groupID))
                }
            case let .challengeStepRankingsFetched(groupID, rankings):
                guard state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                state.rankings = rankings
                return .none
            case .showAlert:
                return .none
            }
        }
    }
}

private extension ChallengeDetailFeature {
    func fetchChallengeStepRankings(groupID: Int) async -> Action {
        do {
            // MARK: 임시 딜레이 코드
            try await Task.sleep(for: .seconds(3))
            let rankings = try await challengeUseCase.fetchChallengeStepRankings(groupId: groupID)
            return .challengeStepRankingsFetched(groupID: groupID, rankings)
        } catch {
            let error = error as? NetworkError ?? .unknown
            guard case let .serverError(code, _, fallback) = error else {
                return .showAlert(error)
            }

            switch code {
            case ServerErrorCode.challenge303.code:
                return .challengeStepRankingsFetched(groupID: groupID, [])
            default:
                return .showAlert(fallback)
            }
        }
    }
}
