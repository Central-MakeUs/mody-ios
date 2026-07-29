//
//  ReminderExerciseSection.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import SwiftUI
import CommonDomain
import DesignSystem

public struct ReminderExerciseSection: View {
    private let width: CGFloat
    private let weekdays: [DayOfWeek]
    private let selectedWeekdays: [DayOfWeek]
    private let schedules: [ExerciseSchedule]
    private let calendar: Calendar
    private let onWeekdayTapped: (DayOfWeek) -> Void
    private let onScheduleTapped: (DayOfWeek) -> Void
    private let onSameTimeTapped: () -> Void

    public init(
        width: CGFloat,
        weekdays: [DayOfWeek],
        selectedWeekdays: [DayOfWeek],
        schedules: [ExerciseSchedule],
        calendar: Calendar,
        onWeekdayTapped: @escaping (DayOfWeek) -> Void,
        onScheduleTapped: @escaping (DayOfWeek) -> Void,
        onSameTimeTapped: @escaping () -> Void
    ) {
        self.width = width
        self.weekdays = weekdays
        self.selectedWeekdays = selectedWeekdays
        self.schedules = schedules
        self.calendar = calendar
        self.onWeekdayTapped = onWeekdayTapped
        self.onScheduleTapped = onScheduleTapped
        self.onSameTimeTapped = onSameTimeTapped
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MText(
                "운동 일정",
                style: .b7,
                color: .gray8
            )

            exerciseDescription

            ReminderWeekdayChips(
                width: width,
                weekdays: weekdays,
                selectedWeekdays: selectedWeekdays,
                onWeekdayTapped: onWeekdayTapped
            )

            if !schedules.isEmpty {
                ReminderExerciseTimeRows(
                    schedules: schedules,
                    calendar: calendar,
                    onScheduleTapped: onScheduleTapped
                )
                .transition(.opacity.combined(with: .move(edge: .top)))

                sameTimeButton
                    .padding(.top, 32)
                    .transition(.opacity)
            }
        }
        .greedyWidth(.leading)
        .animation(.easeInOut(duration: 0.18), value: schedules)
    }
}

private extension ReminderExerciseSection {
    var exerciseDescription: some View {
        (
            Text("운동은 일주일에 ")
                .font(ModyTypography.c2.token.swiftUIFont)
                .foregroundStyle(Color.gray6)
            + Text("최소 한 번")
                .font(ModyTypography.b6.token.swiftUIFont)
                .foregroundStyle(Color.sub)
            + Text("은 해야해요!")
                .font(ModyTypography.c2.token.swiftUIFont)
                .foregroundStyle(Color.gray6)
        )
    }

    var sameTimeButton: some View {
        Button {
            onSameTimeTapped()
        } label: {
            MText(
                "모두 같은 시간으로 설정",
                style: .c2,
                color: .gray9,
                underline: true,
            )
        }
        .greedyWidth()
    }
}
