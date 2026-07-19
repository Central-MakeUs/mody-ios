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
    private let notificationSettingUseCase: MyPageNotificationSettingUseCase
    private let router: @MainActor (MyPageNotificationSettingsRoute) -> Void

    public init(
        notificationPermission: NotificationPermissionInterface,
        notificationSettingUseCase: MyPageNotificationSettingUseCase,
        router: @escaping @MainActor (MyPageNotificationSettingsRoute) -> Void
    ) {
        self.notificationPermission = notificationPermission
        self.notificationSettingUseCase = notificationSettingUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public enum NotificationSettingType: Equatable {
            case comment
            case challenge
            case mealAndExercise
        }

        var isLoading = false
        var isNotificationPermissionGranted = false
        var notificationSetting = NotificationSettingState()

        public init() {}
    }

    public enum Action {
        case onAppear
        case checkNotificationPermission
        case backButtonTapped
        case notificationToggleChanged(State.NotificationSettingType, isOn: Bool)
        case notificationSettingsFetched(NotificationSettingState)
        case notificationSettingsFetchFailed
        case notificationSettingsUpdated(NotificationSettingState)
        case notificationSettingsUpdateFailed
        case setNotificationPermissionGranted(Bool)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .send(.checkNotificationPermission),
                    .run { send in
                        await send(fetchNotificationSettings())
                    }
                )
            case .checkNotificationPermission:
                return .run { send in
                    let isGranted = await currentNotificationPermissionIsGranted()
                    await send(.setNotificationPermissionGranted(isGranted))
                }
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            case let .notificationToggleChanged(type, isOn):
                state.isLoading = true
                var settingState = state.notificationSetting

                switch type {
                case .comment:
                    settingState.commentNotificationEnabled = isOn
                case .challenge:
                    settingState.challengeNotificationEnabled = isOn
                case .mealAndExercise:
                    settingState.mealAndExerciseEnabled = isOn
                }

                return .run { [settingState] send in
                    await send(updateNotificationSettings(settingState))
                }
            case .notificationSettingsFetched(let notificationSetting):
                state.isLoading = false
                state.notificationSetting = notificationSetting
                return .none
            case .notificationSettingsFetchFailed:
                state.isLoading = false
                return .none
            case .notificationSettingsUpdated(let notificationSetting):
                state.isLoading = false
                state.notificationSetting = notificationSetting
                return .none
            case .notificationSettingsUpdateFailed:
                state.isLoading = false
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

    func fetchNotificationSettings() async -> Action {
        do {
            let notificationSetting = try await notificationSettingUseCase.fetchNotificationSettings()
            return .notificationSettingsFetched(notificationSetting)
        } catch {
            return .notificationSettingsFetchFailed
        }
    }

    func updateNotificationSettings(_ notificationSetting: NotificationSettingState) async -> Action {
        do {
            let updatedNotificationSetting = try await notificationSettingUseCase.updateNotificationSettings(
                notificationSetting
            )
            return .notificationSettingsUpdated(updatedNotificationSetting)
        } catch {
            return .notificationSettingsUpdateFailed
        }
    }
}
