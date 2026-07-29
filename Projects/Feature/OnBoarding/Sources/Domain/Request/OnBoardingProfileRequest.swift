//
//  OnBoardingProfileRequest.swift
//  OnBoarding
//
//  Created by 김동준 on 7/8/26
//

import CommonDomain

public struct OnBoardingProfileRequest: Equatable, Encodable {
    public let nickname: String
    public let birthDate: String
    public let currentWeightKg: Double
    public let targetWeightKg: Double
    public let mealSchedules: [MealScheduleRequest]
    public let exerciseSchedules: [ExerciseScheduleRequest]

    public init(
        nickname: String,
        birthDate: String,
        currentWeightKg: Double,
        targetWeightKg: Double,
        mealSchedules: [MealScheduleRequest],
        exerciseSchedules: [ExerciseScheduleRequest]
    ) {
        self.nickname = nickname
        self.birthDate = birthDate
        self.currentWeightKg = currentWeightKg
        self.targetWeightKg = targetWeightKg
        self.mealSchedules = mealSchedules
        self.exerciseSchedules = exerciseSchedules
    }
}
