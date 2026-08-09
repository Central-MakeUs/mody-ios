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
        var stepCountStatus: ChallengeStepCountStatus?

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
        case fetchStepChallengeStatus
        case challengeStepRankingsFetched(groupID: Int, [ChallengeStepRanking])
        case stepChallengeStatusFetched(groupID: Int, ChallengeStepCountStatus)
        case changeChallengeButtonTapped
        case refreshStepButtonTapped
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
                state.stepCountStatus = nil

                return .send(.onAppear)
            case .onAppear:
                switch state.contentState {
                case .loading:
                    return .merge([
                        .send(.fetchChallengeStepRankings),
                        .send(.fetchStepChallengeStatus)
                    ])
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
            case .fetchStepChallengeStatus:
                guard let groupID = state.selectedGroup?.groupId,
                      state.stepCountStatus == nil else {
                    return .none
                }

                return .run { send in
                    await send(fetchStepChallengeStatus(groupID: groupID))
                }
            case let .challengeStepRankingsFetched(groupID, rankings):
                guard state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                state.rankings = rankings
                return .none
            case let .stepChallengeStatusFetched(groupID, status):
                guard state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                state.stepCountStatus = status
                return .none
            case .showAlert:
                return .none
            case .changeChallengeButtonTapped:
                // TODO: 챌린지 변경 Implementation
                return .none
            case .refreshStepButtonTapped:
                guard state.selectedGroup != nil ,
                      state.stepCountStatus != nil else { return .none }
                
                state.stepCountStatus = nil
                return .send(.fetchStepChallengeStatus)
            }
        }
    }
}

private extension ChallengeDetailFeature {
    func fetchChallengeStepRankings(groupID: Int) async -> Action {
        do {
            // MARK: 임시 딜레이 코드
            try await Task.sleep(for: .seconds(5))
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

    func fetchStepChallengeStatus(groupID: Int) async -> Action {
        do {
            let status = try await challengeUseCase.fetchStepChallengeStatus(groupId: groupID)
            return .stepChallengeStatusFetched(groupID: groupID, status)
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
