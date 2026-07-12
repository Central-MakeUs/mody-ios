//
//  ProfileFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/12/26.
//

import ComposableArchitecture
import MyPageInterface

@Reducer
public struct ProfileFeature {
    private let router: @MainActor (MyPageProfileRoute) -> Void

    public init(router: @escaping @MainActor (MyPageProfileRoute) -> Void) {
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case backButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            }
        }
    }
}
