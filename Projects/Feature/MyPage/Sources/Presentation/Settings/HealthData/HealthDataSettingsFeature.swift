//
//  HealthDataSettingsFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import MyPageInterface

@Reducer
public struct HealthDataSettingsFeature {
    private let router: @MainActor (MyPageHealthDataSettingsRoute) -> Void

    public init(router: @escaping @MainActor (MyPageHealthDataSettingsRoute) -> Void) {
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
        Reduce { _, action in
            switch action {
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            }
        }
    }
}
