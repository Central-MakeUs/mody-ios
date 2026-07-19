//
//  NotificationSettingsFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import CoreNotificationInterface
import MyPageInterface

@Reducer
public struct NotificationSettingsFeature {
    private let notificationPermission: NotificationPermissionInterface
    private let router: @MainActor (MyPageNotificationSettingsRoute) -> Void

    public init(
        notificationPermission: NotificationPermissionInterface,
        router: @escaping @MainActor (MyPageNotificationSettingsRoute) -> Void
    ) {
        self.notificationPermission = notificationPermission
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        var isNotificationPermissionGranted = false
        var isMealAndExerciseNotificationEnabled: Bool = false

        public init() {}
    }

    public enum Action {
        case onAppear
        case checkNotificationPermission
        case backButtonTapped
        case notificationToggleChanged(Bool)
        case setNotificationPermissionGranted(Bool)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                return .send(.checkNotificationPermission)
            case .checkNotificationPermission:
                return .run { send in
                    let isGranted = await currentNotificationPermissionIsGranted()
                    await send(.setNotificationPermissionGranted(isGranted))
                }
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            case .notificationToggleChanged(let isOn):
                state.isMealAndExerciseNotificationEnabled = isOn
                // TODO: API 호출, UserDefaults 호출
                return .none
            case .setNotificationPermissionGranted(let isGranted):
                state.isNotificationPermissionGranted = isGranted
                return .none
            }
        }
    }
}

private extension NotificationSettingsFeature {
    func currentNotificationPermissionIsGranted() async -> Bool {
        let isNotDetermined = await notificationPermission.isNotificationPermissionNotDetermined()
        if isNotDetermined {
            return await notificationPermission.requestNotificationPermission()
        }

        return await notificationPermission.isNotificationPermissionGranted()
    }
}
