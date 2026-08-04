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
        enum CancelID {
            case challengeSummary
            case challengeNudgeInfo
        }

        var selectedGroup: GroupModel?
        var summary: ChallengeSummary?
        var nudgeInfos: [ChallengeNudgeInfo]?
        var isNudging = false

        public init() {}
    }

    public enum Action {
        case setSelectedGroup(GroupModel?)
        case onAppear
        case refreshChallengeSummary
        case fetchChallengeSummary
        case fetchChallengeNudgeInfo
        case challengeSummaryFetched(groupID: Int, ChallengeSummary?)
        case challengeNudgeInfoFetched(groupID: Int, [ChallengeNudgeInfo])
        case nudgeButtonTapped(memberID: Int)
        case nudgeStarted
        case nudgeCompleted(nickname: String)
        case nudgeFailed(NetworkError)
        case showAlert(NetworkError)
    }

    public init(challengeUseCase: ChallengeUseCase) {
        self.challengeUseCase = challengeUseCase
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.fetchChallengeSummary),
                    .send(.fetchChallengeNudgeInfo)
                )
            case .refreshChallengeSummary:
                state.summary = nil
                return .send(.fetchChallengeSummary)
            case let .setSelectedGroup(group):
                state.selectedGroup = group
                state.summary = nil
                state.nudgeInfos = nil

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
            case .fetchChallengeNudgeInfo:
                guard let groupID = state.selectedGroup?.groupId,
                      state.nudgeInfos == nil else {
                    return .none
                }

                return .run { send in
                    await send(fetchChallengeNudgeInfo(groupID: groupID))
                }
                .cancellable(id: State.CancelID.challengeNudgeInfo, cancelInFlight: true)
            case let .challengeSummaryFetched(groupID, summary):
                guard state.selectedGroup?.groupId == groupID,
                      let summary = summary else {
                    return .none
                }

                state.summary = summary
                return .none
            case let .challengeNudgeInfoFetched(groupID, nudgeInfos):
                guard state.selectedGroup?.groupId == groupID else {
                    return .none
                }

                state.nudgeInfos = nudgeInfos
                return .none
            case let .nudgeButtonTapped(memberID):
                guard !state.isNudging,
                      let groupID = state.selectedGroup?.groupId,
                      let nudgeInfo = state.nudgeInfos?.first(where: { $0.memberId == memberID }),
                      !nudgeInfo.recordedToday else {
                    return .none
                }

                state.isNudging = true
                return .concatenate(
                    .send(.nudgeStarted),
                    .run { send in
                        await send(
                            nudgeMember(
                                groupID: groupID,
                                memberID: memberID,
                                nickname: nudgeInfo.nickname
                            )
                        )
                    }
                )
            case .nudgeStarted:
                return .none
            case .nudgeCompleted:
                state.isNudging = false
                return .none
            case let .nudgeFailed(error):
                state.isNudging = false
                return .send(.showAlert(error))
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

    func fetchChallengeNudgeInfo(groupID: Int) async -> Action {
        do {
            let nudgeInfos = try await challengeUseCase.fetchChallengeNudgeInfo(groupId: groupID)
            return .challengeNudgeInfoFetched(groupID: groupID, nudgeInfos)
        } catch {
            return .showAlert(error as? NetworkError ?? .unknown)
        }
    }

    func nudgeMember(
        groupID: Int,
        memberID: Int,
        nickname: String
    ) async -> Action {
        do {
            try await challengeUseCase.nudgeMember(
                groupId: groupID,
                memberId: memberID
            )

            return .nudgeCompleted(nickname: nickname)
        } catch {
            return .nudgeFailed(error as? NetworkError ?? .unknown)
        }
    }
}
