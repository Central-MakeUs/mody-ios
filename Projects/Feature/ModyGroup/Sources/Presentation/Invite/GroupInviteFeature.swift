//
//  GroupInviteFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture

@Reducer
public struct GroupInviteFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case backButtonTapped
        case shareButtonTapped
        case doneButtonTapped
    }
    
    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
