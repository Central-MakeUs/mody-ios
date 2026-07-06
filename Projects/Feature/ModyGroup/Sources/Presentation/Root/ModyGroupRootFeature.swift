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
    
    public init(router: @escaping @MainActor (ModyGroupRoute) -> Void) {
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var path: StackState<ModyGroupPath.State> = .init()
        var groupParticipateState: GroupParticipateFeature.State = .init()
    }
    
    public enum Action: BindableAction {
        case path(StackActionOf<ModyGroupPath>)
        case binding(BindingAction<State>)
        case groupParticipateAction(GroupParticipateFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
                
        Reduce { state, action in
            switch action {
            case .path(.element(id: _, action: let action)):
                return .none
            case .groupParticipateAction:
                return .none
            case .path:
                return .none
            case .binding:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
