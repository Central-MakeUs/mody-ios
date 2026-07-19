//
//  MealScheduleRequest+Util.swift
//  CommonDomain
//
//  Created by 김동준 on 7/19/26.
//

public extension MealScheduleRequest {
    static func makeMealScheduleRequests(
        meals: [MealType],
        skippedMeals: [MealType],
        timeForMeal: (MealType) -> String
    ) -> [MealScheduleRequest] {
        meals.map { meal in
            let skipped = skippedMeals.contains(meal)

            return MealScheduleRequest(
                mealType: meal,
                time: skipped ? nil : timeForMeal(meal),
                skipped: skipped
            )
        }
    }
}
