//
//  ReminderExerciseTimeRows.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain
import DesignSystem
import SwiftUI
import Util

public struct ReminderExerciseTimeRows: View {
    private let schedules: [ExerciseSchedule]
    private let calendar: Calendar
    private let onScheduleTapped: (DayOfWeek) -> Void

    public init(
        schedules: [ExerciseSchedule],
        calendar: Calendar,
        onScheduleTapped: @escaping (DayOfWeek) -> Void
    ) {
        self.schedules = schedules
        self.calendar = calendar
        self.onScheduleTapped = onScheduleTapped
    }

    public var body: some View {
        VStack(spacing: 8) {
            ForEach(schedules) { schedule in
                Button {
                    onScheduleTapped(schedule.dayOfWeek)
                } label: {
                    HStack(spacing: 0) {
                        MText(
                            schedule.dayOfWeek.title,
                            style: .b7,
                            color: .gray10
                        )

                        Spacer()

                        MText(
                            schedule.date.toKoreanTimeString(calendar: calendar),
                            style: .b7,
                            color: .gray10
                        )
                    }
                    .padding(12)
                    .background(Color.gray1)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
