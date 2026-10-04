//
//  OnBoardingProfileRequestFixture.swift
//  OnBoardingTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
@testable import OnBoarding

func makeProfileRequest() -> OnBoardingProfileRequest {
    OnBoardingProfileRequest(
        nickname: "모디",
        birthDate: "2000-01-01",
        currentWeightKg: 57,
        targetWeightKg: 60,
        mealSchedules: [MealScheduleRequest(mealType: .breakfast, time: "08:00", skipped: false)],
        exerciseSchedules: [ExerciseScheduleRequest(dayOfWeek: .monday, time: "09:00")]
    )
}
