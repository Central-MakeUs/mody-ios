//
//  ExerciseSchedule.swift
//  OnBoarding
//
//  Created by 김동준 on 7/10/26
//

import Foundation

public struct ExerciseSchedule: Equatable, Identifiable {
    let dayOfWeek: DayOfWeek
    var date: Date

    public var id: String { dayOfWeek.rawValue }
}
