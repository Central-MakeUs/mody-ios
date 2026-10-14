//
//  MyPageDemoNotificationStub.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreNotificationInterface
import MyPage

struct MyPageDemoNotificationPermissionStub: NotificationPermissionInterface {
    private let scenario: MyPageScenario

    init(scenario: MyPageScenario) {
        self.scenario = scenario
    }

    func isNotificationPermissionNotDetermined() async -> Bool {
        scenario == .notificationPermissionRequest
    }
    func isNotificationPermissionGranted() async -> Bool {
        scenario != .notificationPermissionDenied
    }
    func requestNotificationPermission() async -> Bool { true }
}

struct MyPageDemoNotificationRepository: MyPageNotificationSettingRepositoryProtocol {
    private let repository: MyPageNotificationSettingRepository

    init(repository: MyPageNotificationSettingRepository) {
        self.repository = repository
    }

    func getNotificationSettings() async throws -> NotificationSettingState {
        try await repository.getNotificationSettings()
    }

    func patchNotificationSettings(_ notificationSetting: NotificationSettingState) async throws -> NotificationSettingState {
        _ = try await repository.patchNotificationSettings(notificationSetting)
        // Demo의 토글 변경은 아직 저장하지 않은 일정 입력을 유지한다.
        return notificationSetting
    }

    func putSchedules(mealSchedules: [MealScheduleRequest], exerciseSchedules: [ExerciseScheduleRequest]) async throws {
        try await repository.putSchedules(mealSchedules: mealSchedules, exerciseSchedules: exerciseSchedules)
    }
}
