//
//  GroupParticipateFeature.swift
//  ModyGroup
//
//  Created by 김동준 on 6/26/26
//

import ComposableArchitecture

@Reducer
public struct GroupParticipateFeature {
    @ObservableState
    public struct State: Equatable {
        let showSignUpDoneContents: Bool
        let showsBackButton: Bool

        public init(
            showSignUpDoneContents: Bool,
            showsBackButton: Bool
        ) {
            self.showSignUpDoneContents = showSignUpDoneContents
            self.showsBackButton = showsBackButton
        }
    }
    
    public enum Action {
        case backButtonTapped
        case participateButtonTapped
        case createButtonTapped
    }
    
    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
