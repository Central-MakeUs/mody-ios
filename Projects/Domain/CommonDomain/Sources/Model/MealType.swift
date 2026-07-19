//
//  MealType.swift
//  CommonDomain
//
//  Created by 김동준 on 7/19/26.
//

public enum MealType: String, CaseIterable, Identifiable, Equatable, Encodable {
    case breakfast = "BREAKFAST"
    case lunch = "LUNCH"
    case dinner = "DINNER"

    public var id: String { rawValue }
}
