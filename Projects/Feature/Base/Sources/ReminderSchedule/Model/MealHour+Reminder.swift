//
//  MealHour+Reminder.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain

public extension Array where Element == MealHour {
    func hour(for meal: MealType) -> Int {
        first { $0.mealType == meal }?.hour ?? meal.defaultHour
    }

    mutating func setHour(_ hour: Int, for meal: MealType) {
        guard let index = firstIndex(where: { $0.mealType == meal }) else {
            append(MealHour(mealType: meal, hour: hour))
            return
        }
        self[index].hour = hour
    }
}
