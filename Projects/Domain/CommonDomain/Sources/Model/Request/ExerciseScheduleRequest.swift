//
//  ExerciseScheduleRequest.swift
//  CommonDomain
//
//  Created by 김동준 on 7/19/26.
//

public struct ExerciseScheduleRequest: Equatable, Codable {
    public let dayOfWeek: DayOfWeek
    public let time: String

    public init(
        dayOfWeek: DayOfWeek,
        time: String
    ) {
        self.dayOfWeek = dayOfWeek
        self.time = time
    }
}
