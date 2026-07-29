//
//  ExerciseSchedule+Reminder.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain
import Foundation

public extension Array where Element == ExerciseSchedule {
    func date(for day: DayOfWeek, default defaultDate: Date) -> Date {
        first { $0.dayOfWeek == day }?.date ?? defaultDate
    }

    mutating func setDate(_ date: Date, for day: DayOfWeek) {
        guard let index = firstIndex(where: { $0.dayOfWeek == day }) else {
            append(ExerciseSchedule(dayOfWeek: day, date: date))
            return
        }
        self[index].date = date
    }
}
