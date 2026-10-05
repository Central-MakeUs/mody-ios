//
//  MyPageNotificationRepositorySpy.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
@testable import MyPage

final class MyPageNotificationRepositorySpy: MyPageNotificationSettingRepositoryProtocol {
    var fetchResult: Result<NotificationSettingState, Error> = .success(MyPageFixture.settings)
    var updateError: Error?
    private(set) var fetchCount = 0
    private(set) var updates: [NotificationSettingState] = []
    private(set) var schedules: [(meals: [MealScheduleRequest], exercises: [ExerciseScheduleRequest])] = []

    func getNotificationSettings() async throws -> NotificationSettingState {
        fetchCount += 1
        return try fetchResult.get()
    }
    func patchNotificationSettings(_ notificationSetting: NotificationSettingState) async throws -> NotificationSettingState {
        updates.append(notificationSetting)
        if let updateError { throw updateError }
        return notificationSetting
    }
    func putSchedules(mealSchedules: [MealScheduleRequest], exerciseSchedules: [ExerciseScheduleRequest]) async throws {
        schedules.append((mealSchedules, exerciseSchedules))
        if let updateError { throw updateError }
    }
}
