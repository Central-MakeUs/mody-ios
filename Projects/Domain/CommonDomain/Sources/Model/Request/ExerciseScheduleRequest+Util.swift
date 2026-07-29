//
//  ExerciseScheduleRequest+Util.swift
//  CommonDomain
//
//  Created by 김동준 on 7/19/26.
//

public extension ExerciseScheduleRequest {
    static func makeExerciseScheduleRequests(
        selectedWeekdays: [DayOfWeek],
        timeForDay: (DayOfWeek) -> String
    ) -> [ExerciseScheduleRequest] {
        selectedWeekdays
            .sorted()
            .map { dayOfWeek in
                ExerciseScheduleRequest(
                    dayOfWeek: dayOfWeek,
                    time: timeForDay(dayOfWeek)
                )
            }
    }
}
