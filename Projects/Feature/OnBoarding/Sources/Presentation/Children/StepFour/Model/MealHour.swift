//
//  MealHour.swift
//  OnBoarding
//
//  Created by 김동준 on 7/10/26
//

import CommonDomain

public struct MealHour: Equatable, Identifiable {
    let mealType: MealType
    var hour: Int

    public var id: String { mealType.rawValue }
}
