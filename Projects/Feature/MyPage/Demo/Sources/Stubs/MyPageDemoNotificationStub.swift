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

struct MyPageDemoNotificationRepositoryStub: MyPageNotificationSettingRepositoryProtocol {
    private let scenario: MyPageScenario

    init(scenario: MyPageScenario) {
        self.scenario = scenario
    }

    func getNotificationSettings() async throws -> NotificationSettingState {
        if scenario == .notificationLookupFailure {
            throw NetworkError.networkUnavailable
        }
        return NotificationSettingState(
            mealAndExerciseEnabled: scenario != .notificationSaveDisabled,
            commentNotificationEnabled: true,
            challengeNotificationEnabled: true,
            mealSchedules: MealType.allCases.map {
                MealScheduleRequest(mealType: $0, time: "09:00", skipped: false)
            },
            exerciseSchedules: [
                ExerciseScheduleRequest(dayOfWeek: .monday, time: "09:00")
            ]
        )
    }

    func patchNotificationSettings(
        _ notificationSetting: NotificationSettingState
    ) async throws -> NotificationSettingState {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .notificationToggleFailure {
            throw NetworkError.networkUnavailable
        }
        return notificationSetting
    }

    func putSchedules(
        mealSchedules: [MealScheduleRequest],
        exerciseSchedules: [ExerciseScheduleRequest]
    ) async throws {
        if scenario == .notificationSaveFailure {
            throw NetworkError.networkUnavailable
        }
    }
}
