//
//  GroupCreateFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture

@Reducer
public struct GroupCreateFeature {
    @ObservableState
    public struct State: Equatable {
        let showsBackButton: Bool

        public init(showsBackButton: Bool = true) {
            self.showsBackButton = showsBackButton
        }
    }
    
    public enum Action {
        case backButtonTapped
        case nextButtonTapped
    }
    
    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
