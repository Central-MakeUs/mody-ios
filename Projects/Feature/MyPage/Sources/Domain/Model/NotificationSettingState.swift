//
//  NotificationSettingState.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain

public struct NotificationSettingState: Equatable {
    public var mealAndExerciseEnabled: Bool
    public var commentNotificationEnabled: Bool
    public var challengeNotificationEnabled: Bool
    public var mealSchedules: [MealScheduleRequest]
    public var exerciseSchedules: [ExerciseScheduleRequest]

    public init(
        mealAndExerciseEnabled: Bool = false,
        commentNotificationEnabled: Bool = false,
        challengeNotificationEnabled: Bool = false,
        mealSchedules: [MealScheduleRequest] = [],
        exerciseSchedules: [ExerciseScheduleRequest] = []
    ) {
        self.mealAndExerciseEnabled = mealAndExerciseEnabled
        self.commentNotificationEnabled = commentNotificationEnabled
        self.challengeNotificationEnabled = challengeNotificationEnabled
        self.mealSchedules = mealSchedules
        self.exerciseSchedules = exerciseSchedules
    }
}
