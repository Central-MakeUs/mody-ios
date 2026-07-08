//
//  OnBoardingProfileRequest.swift
//  OnBoarding
//
//  Created by 김동준 on 7/8/26
//

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

public struct MealScheduleRequest: Equatable, Encodable {
    public let mealType: MealType
    public let time: String
    public let skipped: Bool

    public init(
        mealType: MealType,
        time: String,
        skipped: Bool
    ) {
        self.mealType = mealType
        self.time = time
        self.skipped = skipped
    }
}

public struct ExerciseScheduleRequest: Equatable, Encodable {
    public let dayOfWeek: DayOfWeek
    public let time: String

    public init(
        dayOfWeek: DayOfWeek,
        time: String
    ) {
        self.dayOfWeek = dayOfWeek
        self.time = time
    }
}

public enum MealType: String, Equatable, Encodable {
    case breakfast = "BREAKFAST"
    case lunch = "LUNCH"
    case dinner = "DINNER"
}

public enum DayOfWeek: String, Equatable, Encodable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
}
