//
//  HealthDataSettingsFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import CoreHealthInterface
import MyPageInterface

@Reducer
public struct HealthDataSettingsFeature {
    private let healthPermissionInterface: HealthPermissionInterface
    private let router: @MainActor (MyPageHealthDataSettingsRoute) -> Void

    public init(
        healthPermissionInterface: HealthPermissionInterface,
        router: @escaping @MainActor (MyPageHealthDataSettingsRoute) -> Void
    ) {
        self.healthPermissionInterface = healthPermissionInterface
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case onAppear
        case backButtonTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .run { _ in
                    if await healthPermissionInterface.shouldShowHealthPermissionPrompt() {
                        _ = await healthPermissionInterface.requestHealthPermission()
                    }
                }
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            }
        }
    }
}
