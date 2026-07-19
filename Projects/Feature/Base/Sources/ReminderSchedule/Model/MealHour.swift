//
//  MealHour.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain

public struct MealHour: Equatable, Identifiable {
    public let mealType: MealType
    public var hour: Int

    public var id: String { mealType.rawValue }

    public init(mealType: MealType, hour: Int) {
        self.mealType = mealType
        self.hour = hour
    }
}
