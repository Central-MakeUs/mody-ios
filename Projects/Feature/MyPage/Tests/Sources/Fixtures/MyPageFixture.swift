//
//  MyPageFixture.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreAuthTesting
@testable import MyPage

enum MyPageFixture {
    static let profile = MyPageProfile(socialLoginType: .kakao, name: "모디", birthDate: "2000-01-02")
    static let weight = WeightRecord(startWeightKg: 80, currentWeightKg: 72, targetWeightKg: 65)
    static let user = UserInfoFixture.make(daysTogether: 20)
    static let settings = NotificationSettingState(
        mealAndExerciseEnabled: true, commentNotificationEnabled: true,
        mealSchedules: [MealScheduleRequest(mealType: .breakfast, time: "08:00", skipped: false)],
        exerciseSchedules: [ExerciseScheduleRequest(dayOfWeek: .monday, time: "09:00")]
    )
}
