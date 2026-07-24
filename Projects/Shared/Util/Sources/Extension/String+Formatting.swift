//
//  String+Formatting.swift
//  Util
//
//  Created by 김동준 on 7/10/26
//

import Foundation

public extension String {
    static func toHourMinString(
        hour: Int,
        minute: Int
    ) -> String {
        String(format: "%02d:%02d", hour, minute)
    }

    func toHourMinDate(calendar: Calendar = Date.koreanCalendar) -> Date? {
        let timeComponents = split(separator: ":", omittingEmptySubsequences: false)

        guard
            timeComponents.count >= 2,
            let hour = Int(timeComponents[0]),
            let minute = Int(timeComponents[1]),
            (0...23).contains(hour),
            (0...59).contains(minute)
        else {
            return nil
        }

        return Date.fixedDateForHourMinTime(
            hour: hour,
            minute: minute,
            calendar: calendar
        )
    }

    func toDate(
        format: DateFormat = .yyyyMMdd,
        locale: Locale = Date.koreanLocale,
        timeZone: TimeZone = Date.koreanTimeZone
    ) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = format.value
        formatter.isLenient = false

        return formatter.date(from: self)
    }

    func toISO8601Date() -> Date? {
        let formatter = ISO8601DateFormatter()

        if let date = formatter.date(from: self) {
            return date
        }

        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter.date(from: self)
    }
}
