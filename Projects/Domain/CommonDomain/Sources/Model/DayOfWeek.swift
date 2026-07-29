//
//  DayOfWeek.swift
//  CommonDomain
//
//  Created by 김동준 on 7/9/26
//

public enum DayOfWeek: String, CaseIterable, Identifiable, Equatable, Comparable, Codable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"

    public var id: String { rawValue }

    public static func < (lhs: DayOfWeek, rhs: DayOfWeek) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    public var title: String {
        switch self {
        case .monday: "월"
        case .tuesday: "화"
        case .wednesday: "수"
        case .thursday: "목"
        case .friday: "금"
        case .saturday: "토"
        case .sunday: "일"
        }
    }

    public var sortOrder: Int {
        switch self {
        case .monday: 1
        case .tuesday: 2
        case .wednesday: 3
        case .thursday: 4
        case .friday: 5
        case .saturday: 6
        case .sunday: 7
        }
    }
}
