//
//  SignInFeature.swift
//  SignIn
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import SignInInterface

@Reducer
public struct SignInFeature {
    private let router: @MainActor (SignInRoute) -> Void
    
    public init(router: @escaping @MainActor (SignInRoute) -> Void) {
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case mainButtonTapped
        case onBoardingButtonTapped
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .mainButtonTapped:
                return .run { [router] _ in
                    await router(.routeToMain)
                }
            case .onBoardingButtonTapped:
                return .run { [router] _ in
                    await router(.routeToOnBoarding)
                }
            }
        }
    }
}
