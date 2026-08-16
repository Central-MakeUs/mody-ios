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
        enum ContentState {
            case loading
            case empty
            case content
        }

        enum CancelID {
            case challengeSummary
            case challengeNudgeInfo
        }

        var selectedGroup: GroupModel?
        var summary: ChallengeSummary?
        var nudgeInfos: [ChallengeNudgeInfo]?
        var isNudging = false

        var contentState: ContentState {
            guard let nudgeInfos else { return .loading }
            return nudgeInfos.isEmpty ? .empty : .content
        }

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
        case nudgeCompleted(groupID: Int, memberID: Int, nickname: String)
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
                switch state.contentState {
                case .loading:
                    return .send(.fetchChallengeNudgeInfo)
                case .empty:
                    return .none
                case .content:
                    return .send(.fetchChallengeSummary)
                }
            case .refreshChallengeSummary:
                state.summary = nil

                guard state.nudgeInfos?.isEmpty == false else {
                    return .none
                }

                return .send(.fetchChallengeSummary)
            case let .setSelectedGroup(group):
                state.selectedGroup = group
                state.summary = nil
                state.nudgeInfos = nil

                return .send(.fetchChallengeNudgeInfo)
            case .fetchChallengeSummary:
                guard let groupID = state.selectedGroup?.groupId,
                      state.nudgeInfos?.isEmpty == false,
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
                return nudgeInfos.isEmpty ? .none : .send(.fetchChallengeSummary)
            case let .nudgeButtonTapped(memberID):
                guard !state.isNudging,
                      let groupID = state.selectedGroup?.groupId,
                      let nudgeInfo = state.nudgeInfos?.first(where: { $0.memberId == memberID }),
                      nudgeInfo.buttonStatus == .available else {
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
            case let .nudgeCompleted(groupID, memberID, _):
                state.isNudging = false

                guard state.selectedGroup?.groupId == groupID,
                      let index = state.nudgeInfos?.firstIndex(where: { $0.memberId == memberID }),
                      let nudgeInfo = state.nudgeInfos?[index] else {
                    return .none
                }

                state.nudgeInfos?[index] = ChallengeNudgeInfo(
                    memberId: nudgeInfo.memberId,
                    nickname: nudgeInfo.nickname,
                    profileImageUrl: nudgeInfo.profileImageUrl,
                    recordedToday: nudgeInfo.recordedToday,
                    buttonStatus: .nudged
                )
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

            return .nudgeCompleted(
                groupID: groupID,
                memberID: memberID,
                nickname: nickname
            )
        } catch {
            return .nudgeFailed(error as? NetworkError ?? .unknown)
        }
    }
}
