//
//  ModyGroupRootFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture
import ModyGroupInterface

@Reducer
public struct ModyGroupRootFeature {
    private let router: @MainActor (ModyGroupRoute) -> Void
    
    public init(
        router: @escaping @MainActor (ModyGroupRoute) -> Void
    ) {
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        let entryPoint: ModyGroupEntryPoint
        let showSignUpDoneContents: Bool
        let initialScreen: ModyGroupInitialScreen
        
        var path: StackState<ModyGroupPath.State> = .init()
        var groupParticipateState: GroupParticipateFeature.State
        var groupCreateState: GroupCreateFeature.State = .init()

        public init(
            entryPoint: ModyGroupEntryPoint,
            showSignUpDoneContents: Bool,
            initialScreen: ModyGroupInitialScreen
        ) {
            self.entryPoint = entryPoint
            self.showSignUpDoneContents = showSignUpDoneContents
            self.initialScreen = initialScreen
            self.groupParticipateState = .init(
                showSignUpDoneContents: showSignUpDoneContents,
                showsBackButton: entryPoint == .main
            )
            self.groupCreateState = .init(
                showsBackButton: entryPoint == .main && initialScreen != .create
            )
        }
    }
    
    public enum Action: BindableAction {
        case path(StackActionOf<ModyGroupPath>)
        case binding(BindingAction<State>)
        case groupParticipateAction(GroupParticipateFeature.Action)
        case groupCreateAction(GroupCreateFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.groupParticipateState, action: \.groupParticipateAction) {
            GroupParticipateFeature()
        }
        Scope(state: \.groupCreateState, action: \.groupCreateAction) {
            GroupCreateFeature()
        }
                
        Reduce { state, action in
            switch action {
            case .path(.element(id: _, action: let action)):
                return handlePathAction(&state, action)
            case .groupParticipateAction(let action):
                return handleGroupParticipateAction(&state, action)
            case .groupCreateAction(let action):
                return handleCreateFromMainAction(&state, action)
            case .path:
                return .none
            case .binding:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

private extension ModyGroupRootFeature {
    func handlePathAction(
        _ state: inout State,
        _ action: ModyGroupPath.Action
    ) -> Effect<Action> {
        switch action {
        case .create(let createAction):
            return handleCreateFromRootAction(&state, createAction)
        case .invite(let inviteAction):
            return handleInviteAction(&state, inviteAction)
        }
    }

    func handleGroupParticipateAction(
        _ state: inout State,
        _ action: GroupParticipateFeature.Action
    ) -> Effect<Action> {
        switch action {
        case .backButtonTapped:
            return .run { [router] _ in
                await router(.back)
            }
        case .participateButtonTapped:
            return .run { [router] _ in
                await router(.finish)
            }
        case .createButtonTapped:
            state.path.append(.create(.init()))
            return .none
        }
    }
    
    func handleCreateFromRootAction(
        _ state: inout State,
        _ action: GroupCreateFeature.Action
    ) -> Effect<Action> {
        switch action {
        case .backButtonTapped:
            state.path.removeLast()
            return .none
        case .nextButtonTapped:
            state.path.append(.invite(.init()))
            return .none
        }
    }
    
    func handleInviteAction(
        _ state: inout State,
        _ action: GroupInviteFeature.Action
    ) -> Effect<Action> {
        switch action {
        case .backButtonTapped:
            state.path.removeLast()
            return .none
        case .doneButtonTapped:
            return .run { [router] _ in
                await router(.finish)
            }
        default:
            return .none
        }
    }

    func handleCreateFromMainAction(
        _ state: inout State,
        _ action: GroupCreateFeature.Action
    ) -> Effect<Action> {
        switch action {
        case .backButtonTapped:
            return .run { [router] _ in
                await router(.back)
            }
        case .nextButtonTapped:
            state.path.append(.invite(.init()))
            return .none
        }
    }
}
