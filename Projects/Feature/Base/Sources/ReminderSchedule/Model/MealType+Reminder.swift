//
//  MealType+Reminder.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain

public extension MealType {
    var title: String {
        switch self {
        case .breakfast: "아침 식사"
        case .lunch: "점심 식사"
        case .dinner: "저녁 식사"
        }
    }

    var defaultHour: Int {
        switch self {
        case .breakfast: 8
        case .lunch: 12
        case .dinner: 18
        }
    }

    var selectableHours: [Int] {
        switch self {
        case .breakfast: Array(7...11)
        case .lunch: Array(12...16)
        case .dinner: Array(17...21)
        }
    }
}
