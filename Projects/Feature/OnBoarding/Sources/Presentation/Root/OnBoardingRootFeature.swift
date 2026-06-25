//
//  OnBoardingRootFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture

@Reducer
public struct OnBoardingRootFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var path: StackState<OnBoardingPath.State> = .init()
        var onBoardingState: OnBoardingFeature.State = .init()
    }
    
    public enum Action: BindableAction {
        case path(StackActionOf<OnBoardingPath>)
        case binding(BindingAction<State>)
        case onBoardingAction(OnBoardingFeature.Action)
    }
    
    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()
                
        Reduce { state, action in
            switch action {
            case .path(.element(id: _, action: let action)):
                return .none
            case .onBoardingAction:
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
