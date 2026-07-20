//
//  GroupSettingsFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import Base
import CommonDomain
import ComposableArchitecture
import MyPageInterface
import ModyGroupInterface

@Reducer
public struct GroupSettingsFeature {
    private let groupUseCase: GroupUseCaseProtocol
    private let router: @MainActor (MyPageGroupSettingsRoute) -> Void

    public init(
        groupUseCase: GroupUseCaseProtocol,
        router: @escaping @MainActor (MyPageGroupSettingsRoute) -> Void
    ) {
        self.groupUseCase = groupUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        enum AlertCase: Equatable {
            case exitConfirmation(groupID: Int)
            case error(NetworkError)
        }

        var alertCase: AlertCase?
        var alertState = AlertFeature.State(dismissOnScrimTap: false)
        var groups: [GroupModel] = []
        var isLoading = false

        public init() {}
    }

    public enum Action {
        case alertAction(AlertFeature.Action)
        case onAppear
        case backButtonTapped
        case routeToGroupParticipate
        case exitButtonTapped(groupID: Int)
        case exitConfirmationTapped
        case groupsFetched([GroupModel])
        case groupsFetchFailed(NetworkError)
        case groupExited(groupID: Int)
        case groupExitFailed(NetworkError)
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
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(fetchGroups())
                }
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            case .routeToGroupParticipate:
                return .run { [router] _ in
                    await router(.routeToGroupParticipate)
                }
            case let .exitButtonTapped(groupID):
                state.alertCase = .exitConfirmation(groupID: groupID)
                return .send(.alertAction(.present))
            case .exitConfirmationTapped:
                guard case let .exitConfirmation(groupID) = state.alertCase else {
                    return .none
                }
                state.isLoading = true
                return .merge(
                    .send(.alertAction(.dismiss)),
                    .run { send in
                        await send(exitGroup(groupID: groupID))
                    }
                )
            case let .groupsFetched(groups):
                state.groups = groups
                state.isLoading = false
                return .none
            case let .groupsFetchFailed(error):
                state.isLoading = false
                state.alertCase = .error(error)
                return .send(.alertAction(.present))
            case let .groupExited(groupID):
                state.groups.removeAll { $0.groupId == groupID }
                state.isLoading = false

                if state.groups.isEmpty {
                    return .send(.routeToGroupParticipate)
                }

                return .none
            case let .groupExitFailed(error):
                state.isLoading = false
                state.alertCase = .error(error)
                return .send(.alertAction(.present))
            }
        }
    }
}

private extension GroupSettingsFeature {
    func fetchGroups() async -> Action {
        do {
            let groups = try await groupUseCase.getGroups()
            return .groupsFetched(groups)
        } catch {
            return .groupsFetchFailed(error as? NetworkError ?? .unknown)
        }
    }

    func exitGroup(groupID: Int) async -> Action {
        do {
            try await groupUseCase.exitGroup(groupId: groupID)
            return .groupExited(groupID: groupID)
        } catch {
            return .groupExitFailed(error as? NetworkError ?? .unknown)
        }
    }
}
