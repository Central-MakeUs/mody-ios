//
//  MealAndExerciseScheduleRequest.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain

struct MealAndExerciseScheduleRequest: Encodable, Equatable {
    let mealSchedules: [MealScheduleRequest]
    let exerciseSchedules: [ExerciseScheduleRequest]

    init(
        mealSchedules: [MealScheduleRequest],
        exerciseSchedules: [ExerciseScheduleRequest]
    ) {
        self.mealSchedules = mealSchedules
        self.exerciseSchedules = exerciseSchedules
    }
}
