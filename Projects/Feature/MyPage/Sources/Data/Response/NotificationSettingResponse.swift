//
//  NotificationSettingResponse.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain

struct NotificationSettingResponse: Decodable, Equatable {
    let mealAndExerciseEnabled: Bool?
    let commentNotificationEnabled: Bool?
    let challengeNotificationEnabled: Bool?
    let mealSchedules: [MealScheduleRequest]?
    let exerciseSchedules: [ExerciseScheduleRequest]?

    private enum CodingKeys: String, CodingKey {
        case mealAndExerciseEnabled = "recordReminderEnabled"
        case commentNotificationEnabled
        case challengeNotificationEnabled
        case mealSchedules
        case exerciseSchedules
    }

    func toDomain() -> NotificationSettingState {
        NotificationSettingState(
            mealAndExerciseEnabled: mealAndExerciseEnabled ?? false,
            commentNotificationEnabled: commentNotificationEnabled ?? false,
            challengeNotificationEnabled: challengeNotificationEnabled ?? false,
            mealSchedules: mealSchedules ?? [],
            exerciseSchedules: exerciseSchedules ?? []
        )
    }
}
