//
//  MyPageFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/12/26.
//

import ComposableArchitecture
import MyPageInterface

@Reducer
public struct MyPageFeature {
    private let router: @MainActor (MyPageRoute) -> Void

    public init(router: @escaping @MainActor (MyPageRoute) -> Void) {
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case profileButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .profileButtonTapped:
                return .run { [router] _ in
                    await router(.routeToProfile)
                }
            }
        }
    }
}
