//
//  ExerciseSchedule.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain
import Foundation

public struct ExerciseSchedule: Equatable, Identifiable {
    public let dayOfWeek: DayOfWeek
    public var date: Date

    public var id: String { dayOfWeek.rawValue }

    public init(dayOfWeek: DayOfWeek, date: Date) {
        self.dayOfWeek = dayOfWeek
        self.date = date
    }
}
