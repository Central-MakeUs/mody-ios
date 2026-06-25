//
//  SplashFeature.swift
//  Splash
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import SplashInterface

@Reducer
public struct SplashFeature {
    private let router: @MainActor (SplashRoute) -> Void
    
    public init(router: @escaping @MainActor (SplashRoute) -> Void) {
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case onAppear
    }
    
    public var body: some ReducerOf<Self> {
                
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
