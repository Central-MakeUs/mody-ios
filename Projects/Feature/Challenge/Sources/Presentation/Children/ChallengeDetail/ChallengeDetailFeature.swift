//
//  ChallengeDetailFeature.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import ComposableArchitecture
import CommonDomain
import CoreHealthInterface
import ModyLogger
import Foundation
import Util

@Reducer
public struct ChallengeDetailFeature {
    private let challengeUseCase: ChallengeUseCase
    private let healthUseCase: HealthUseCaseProtocol
    @Dependency(\.continuousClock) private var clock

    @ObservableState
    public struct State: Equatable {
        enum ContentState {
            case loading
            case empty
            case content
        }

        enum CancelID {
            case myStepCountFetch
            case myStepCountTimer
            case stepChallengeStatus
        }

        var selectedGroup: GroupModel?
        var rankings: [ChallengeStepRanking]?
        var stepCountStatus: ChallengeStepCountStatus?
        var currentStepCountFromHealthKit: Int?

        var contentState: ContentState {
            guard let rankings else { return .loading }
            return rankings.isEmpty ? .empty : .content
        }

        public init() {}
    }

    public enum Action {
        case setSelectedGroup(GroupModel?)
        case onAppear
        case onDisappear
        case fetchChallengeStepRankings
        case fetchStepChallengeStatus
        case startMyStepCountTimer
        case fetchMyStepCount
        case updateChallengeStepCount(groupID: Int, stepCount: Int)
        case challengeStepRankingsFetched(groupID: Int, [ChallengeStepRanking])
        case stepChallengeStatusFetched(groupID: Int, ChallengeStepCountStatus)
        case changeChallengeButtonTapped
        case refreshStepButtonTapped
        case showAlert(NetworkError)
    }

    public init(
        challengeUseCase: ChallengeUseCase,
        healthUseCase: HealthUseCaseProtocol
    ) {
        self.challengeUseCase = challengeUseCase
        self.healthUseCase = healthUseCase
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .setSelectedGroup(group):
                state.selectedGroup = group
                state.rankings = nil
                state.stepCountStatus = nil
                state.currentStepCountFromHealthKit = nil

                return .concatenate(
                    .merge(
                        .cancel(id: State.CancelID.myStepCountFetch),
                        .cancel(id: State.CancelID.myStepCountTimer),
                        .cancel(id: State.CancelID.stepChallengeStatus)
                    ),
                    .send(.onAppear)
                )
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
            case .onDisappear:
                return .merge(
                    .cancel(id: State.CancelID.myStepCountFetch),
                    .cancel(id: State.CancelID.myStepCountTimer),
                    .cancel(id: State.CancelID.stepChallengeStatus)
                )
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
                .cancellable(id: State.CancelID.stepChallengeStatus, cancelInFlight: true)
            case .startMyStepCountTimer:
                return .run { [clock] send in
                    for await _ in clock.timer(interval: .seconds(5)) {
                        await send(.fetchMyStepCount)
                    }
                }
                .cancellable(id: State.CancelID.myStepCountTimer, cancelInFlight: true)
            case .fetchMyStepCount:
                guard let groupID = state.selectedGroup?.groupId,
                      let startDate = state.stepCountStatus?.stepCountFetchFromAt else {
                    return .none
                }

                return .run { send in
                    do {
                        let now = Date.now
                        let stepCount = try await healthUseCase.getStepCount(
                            from: startDate,
                            to: now
                        )
                        await send(.updateChallengeStepCount(groupID: groupID, stepCount: stepCount))
                        ModyLogger.debug("Challenge my step count: \(stepCount)")
                    } catch {
                        ModyLogger.debug("Challenge my step count fetch failed: \(error)")
                    }
                }
                .cancellable(id: State.CancelID.myStepCountFetch, cancelInFlight: true)
            case let .updateChallengeStepCount(groupID, stepCount):
                guard state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                let needStepCountUpdate = state.currentStepCountFromHealthKit != stepCount
                state.currentStepCountFromHealthKit = stepCount

                guard needStepCountUpdate else { return .none }

                let request = ChallengeStepCountRequest(
                    recordedOn: Date.now.toString(format: .yyyyMMdd),
                    stepCount: stepCount
                )
                return .run { _ in
                    try? await challengeUseCase.updateChallengeStepCount(
                        groupId: groupID,
                        request: request
                    )
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
                return .send(.startMyStepCountTimer)
            case .showAlert:
                return .none
            case .changeChallengeButtonTapped:
                // TODO: 챌린지 변경 Implementation
                return .none
            case .refreshStepButtonTapped:
                guard state.selectedGroup != nil ,
                      state.stepCountStatus != nil else { return .none }
                
                state.stepCountStatus = nil
                return .merge(
                    .cancel(id: State.CancelID.myStepCountFetch),
                    .cancel(id: State.CancelID.myStepCountTimer),
                    .cancel(id: State.CancelID.myStepCountUpdate),
                    .send(.fetchStepChallengeStatus)
                )
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
                return .stepChallengeStatusFetched(groupID: groupID, .init())
            default:
                return .showAlert(fallback)
            }
        }
    }
}
