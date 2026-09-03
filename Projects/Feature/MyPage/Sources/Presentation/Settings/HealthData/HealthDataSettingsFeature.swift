//
//  HealthDataSettingsFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import CoreAnalyticsInterface
import CoreHealthInterface
import MyPageInterface

@Reducer
public struct HealthDataSettingsFeature {
    private let healthPermissionInterface: HealthPermissionInterface
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private let router: @MainActor (MyPageHealthDataSettingsRoute) -> Void

    public init(
        healthPermissionInterface: HealthPermissionInterface,
        analyticsUseCase: AnalyticsUseCaseProtocol,
        router: @escaping @MainActor (MyPageHealthDataSettingsRoute) -> Void
    ) {
        self.healthPermissionInterface = healthPermissionInterface
        self.analyticsUseCase = analyticsUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case onAppear
        case backButtonTapped
        case healthAppButtonTapped
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
            case .healthAppButtonTapped:
                return .run { _ in
                    analyticsUseCase.log(MyPageAnalyticsEvent.healthAppOpenClicked)
                }
            }
        }
    }
}
