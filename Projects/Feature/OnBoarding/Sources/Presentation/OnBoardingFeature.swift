//
//  OnBoardingFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import OnBoardingInterface

@Reducer
public struct OnBoardingFeature {
    private let router: @MainActor (OnBoardingRoute) -> Void

    public init(router: @escaping @MainActor (OnBoardingRoute) -> Void) {
        self.router = router
    }
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case signUpDoneButtonTapped
    }
    
    public var body: some ReducerOf<Self> {
                
        Reduce { state, action in
            switch action {
            case .signUpDoneButtonTapped:
                return .run { [router] _ in
                    await router(.routeToSignUpDone)
                }
            }
        }
    }
}
