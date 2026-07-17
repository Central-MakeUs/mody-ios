//
//  FeedWeekCalendarCalculator.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

import Foundation
import CommonDomain
import Util

struct FeedWeekCalendarCalculator {
    static let weekdays: [DayOfWeek] = [
        .sunday,
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday
    ]

    struct WeekInfo: Equatable {
        let month: Int
        let weekOfMonth: Int

        var title: String {
            "\(month)월 \(weekOfMonth)주차"
        }
    }

    static func calculateWeekInfoFromBaseDate(
        _ baseDate: Date,
        calendar: Calendar = Date.koreanCalendar
    ) -> WeekInfo {
        let weekStart = getStartOfWeekFromBaseDate(baseDate, calendar: calendar)
        let wednesday = date(
            byAdding: .day,
            value: 3,
            to: weekStart,
            calendar: calendar
        )
        let components = calendar.dateComponents([.month, .day], from: wednesday)
        let month = components.month ?? 1
        let day = components.day ?? 1

        return WeekInfo(
            month: month,
            weekOfMonth: ((day - 1) / 7) + 1
        )
    }

    static func makeModels(
        containing baseDate: Date,
        recordedDates: Set<String> = [],
        calendar: Calendar = Date.koreanCalendar
    ) -> [FeedWeekCalendarModel] {
        let weekStart = getStartOfWeekFromBaseDate(baseDate, calendar: calendar)

        return weekdays.enumerated().map { index, dayOfWeek in
            let date = date(
                byAdding: .day,
                value: index,
                to: weekStart,
                calendar: calendar
            )
            let dateString = date.toString()

            return FeedWeekCalendarModel(
                date: dateString,
                dayOfWeek: dayOfWeek,
                hasRecord: recordedDates.contains(dateString)
            )
        }
    }

    static func isSelectable(
        date: String,
        latestSelectableDate: String,
        calendar: Calendar = Date.koreanCalendar
    ) -> Bool {
        guard let date = parseDate(date),
              let latestSelectableDate = parseDate(latestSelectableDate) else {
            return false
        }

        return calendar.compare(
            date,
            to: latestSelectableDate,
            toGranularity: .day
        ) != .orderedDescending
    }

    static func parseDate(_ date: String) -> Date? {
        date.toDate(format: .yyyyMMdd)
    }
}

private extension FeedWeekCalendarCalculator {
    static func getStartOfWeekFromBaseDate(
        _ baseDate: Date,
        calendar: Calendar
    ) -> Date {
        let startOfDay = calendar.startOfDay(for: baseDate)
        let weekday = calendar.component(.weekday, from: startOfDay)

        return date(
            byAdding: .day,
            value: -(weekday - 1),
            to: startOfDay,
            calendar: calendar
        )
    }

    static func date(
        byAdding component: Calendar.Component,
        value: Int,
        to baseDate: Date,
        calendar: Calendar
    ) -> Date {
        guard let calculatedDate = calendar.date(
            byAdding: component,
            value: value,
            to: baseDate
        ) else {
            assertionFailure("주간 캘린더 날짜 계산에 실패했습니다.")
            return baseDate
        }

        return calculatedDate
    }
}
