//
//  MyPageNotificationSettingUseCase.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain

public struct MyPageNotificationSettingUseCase {
    private let repository: MyPageNotificationSettingRepositoryProtocol

    public init(repository: MyPageNotificationSettingRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchNotificationSettings() async throws -> NotificationSettingState {
        try await repository.getNotificationSettings()
    }

    public func updateNotificationSettings(_ notificationSetting: NotificationSettingState) async throws -> NotificationSettingState {
        try await repository.patchNotificationSettings(notificationSetting)
    }

    public func updateSchedules(mealSchedules: [MealScheduleRequest], exerciseSchedules: [ExerciseScheduleRequest]) async throws {
        try await repository.putSchedules(mealSchedules: mealSchedules, exerciseSchedules: exerciseSchedules)
    }
}
