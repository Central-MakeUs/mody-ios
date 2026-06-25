//
//  SignInFeature.swift
//  SignIn
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture

@Reducer
public struct SignInFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
    }
    
    public init() {}
    public var body: some ReducerOf<Self> {
                
        Reduce { state, action in
            return .none
        }
    }
}
