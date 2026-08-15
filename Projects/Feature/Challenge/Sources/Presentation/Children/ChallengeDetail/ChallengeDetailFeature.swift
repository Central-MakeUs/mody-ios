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
        var currentWeeklyChallengeList: [CurrentWeeklyChallenge]?
        var currentStepCountFromHealthKit: Int?

        var hasValidRankings: Bool {
            (rankings?.count ?? 0) > 1
        }

        var contentState: ContentState {
            guard rankings != nil else { return .loading }
            return hasValidRankings ? .content : .empty
        }

        public init() {}
    }

    public enum Action {
        case setSelectedGroup(GroupModel?)
        case stepChallengeChanged
        case onAppear
        case fetchChallengeStepRankings
        case fetchStepChallengeStatus
        case fetchCurrentWeeklyChallenge
        case refreshCurrentWeeklyChallenge
        case startMyStepCountTimer
        case fetchMyStepCount
        case updateChallengeStepCount(groupID: Int, stepCount: Int)
        case challengeStepRankingsFetched(groupID: Int, [ChallengeStepRanking])
        case stepChallengeStatusFetched(groupID: Int, ChallengeStepCountStatus)
        case currentWeeklyChallengeListFetched(groupID: Int, [CurrentWeeklyChallenge])
        case changeChallengeButtonTapped
        case weeklyChallengeTapped(challengeId: Int, groupChallengeId: Int)
        case refreshStepButtonTapped
        case showAlert(NetworkError)
        case refresh
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
                return .send(.refresh)
            case .refresh:
                state.rankings = nil
                state.stepCountStatus = nil
                state.currentStepCountFromHealthKit = nil
                state.currentWeeklyChallengeList = nil

                return .concatenate(
                    .merge(
                        .cancel(id: State.CancelID.myStepCountFetch),
                        .cancel(id: State.CancelID.myStepCountTimer),
                        .cancel(id: State.CancelID.stepChallengeStatus)
                    ),
                    .send(.onAppear)
                )
            case .stepChallengeChanged:
                return .send(.refresh)
            case .onAppear:
                switch state.contentState {
                case .loading:
                    return .merge([
                        .send(.fetchChallengeStepRankings),
                        .send(.fetchStepChallengeStatus),
                        .send(.fetchCurrentWeeklyChallenge)
                    ])
                case .empty:
                    return .none
                case .content:
                    return .send(.startMyStepCountTimer)
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
                .cancellable(id: State.CancelID.stepChallengeStatus, cancelInFlight: true)
            case .fetchCurrentWeeklyChallenge:
                guard let groupID = state.selectedGroup?.groupId,
                      state.currentWeeklyChallengeList == nil else {
                    return .none
                }

                return .run { send in
                    await send(fetchCurrentWeeklyChallenge(groupID: groupID))
                }
            case .refreshCurrentWeeklyChallenge:
                guard let groupID = state.selectedGroup?.groupId else {
                    return .none
                }
                
                state.currentWeeklyChallengeList = nil

                return .run { send in
                    await send(fetchCurrentWeeklyChallenge(groupID: groupID))
                }
            case .startMyStepCountTimer:
                guard state.hasValidRankings,
                      state.stepCountStatus?.isComplete != true else {
                    return .none
                }

                return .run { [clock] send in
                    for await _ in clock.timer(interval: .seconds(5)) {
                        await send(.fetchMyStepCount)
                    }
                }
                .cancellable(id: State.CancelID.myStepCountTimer, cancelInFlight: true)
            case .fetchMyStepCount:
                guard state.hasValidRankings,
                      let groupID = state.selectedGroup?.groupId,
                      let startDate = state.stepCountStatus?.stepCountFetchFromAt else {
                    return .none
                }
                
                if let isCompleteGroup = state.stepCountStatus?.isComplete {
                    if isCompleteGroup { return .cancel(id: State.CancelID.myStepCountTimer) }
                }

                return .run { send in
                    do {
                        let now = Date.now
                        ModyLogger.debug("Challenge Step 범위 \(startDate) ~ \(now)")
                        let stepCount = try await healthUseCase.getStepCount(
                            from: startDate,
                            to: now
                        )
                        await send(.updateChallengeStepCount(groupID: groupID, stepCount: stepCount))
                    } catch {
                        ModyLogger.debug("Challenge my step count fetch failed: \(error)")
                    }
                }
                .cancellable(id: State.CancelID.myStepCountFetch, cancelInFlight: true)
            case let .updateChallengeStepCount(groupID, stepCount):
                guard state.hasValidRankings,
                      state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                let needStepCountUpdate = state.currentStepCountFromHealthKit != stepCount
                state.currentStepCountFromHealthKit = stepCount

                guard needStepCountUpdate else {
                    ModyLogger.debug("Step Count Skip!!!!: \(stepCount)")
                    return .none
                }

                let request = ChallengeStepCountRequest(
                    recordedOn: Date.now.toString(format: .yyyyMMdd),
                    stepCount: stepCount
                )
                return .run { _ in
                    try? await challengeUseCase.updateChallengeStepCount(
                        groupId: groupID,
                        request: request
                    )
                    ModyLogger.debug("Step Count 등록: \(stepCount)")
                }
            case let .challengeStepRankingsFetched(groupID, rankings):
                guard state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                state.rankings = rankings
                guard state.hasValidRankings else {
                    state.currentStepCountFromHealthKit = nil
                    return .none
                }

                return .send(.startMyStepCountTimer)
            case let .stepChallengeStatusFetched(groupID, status):
                guard state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                state.stepCountStatus = status
                guard status.isComplete else { return .none }

                return .cancel(id: State.CancelID.myStepCountTimer)
            case let .currentWeeklyChallengeListFetched(groupID, weeklyChallengeList):
                guard state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                state.currentWeeklyChallengeList = weeklyChallengeList
                return .none
            case .showAlert:
                return .none
            case .changeChallengeButtonTapped:
                return .none
            case .weeklyChallengeTapped:
                return .none
            case .refreshStepButtonTapped:
                guard let group = state.selectedGroup ,
                      state.stepCountStatus != nil else { return .none }
                
                return .send(.setSelectedGroup(group))
            }
        }
    }
}

private extension ChallengeDetailFeature {
    func fetchChallengeStepRankings(groupID: Int) async -> Action {
        do {
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

    func fetchCurrentWeeklyChallenge(groupID: Int) async -> Action {
        do {
            let weeklyChallengeList = try await challengeUseCase.fetchCurrentWeeklyChallenge(
                groupId: groupID
            )
            return .currentWeeklyChallengeListFetched(
                groupID: groupID,
                weeklyChallengeList
            )
        } catch {
            return .showAlert(error as? NetworkError ?? .unknown)
        }
    }
}
