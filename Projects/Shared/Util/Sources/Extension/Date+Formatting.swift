//
//  Date+Formatting.swift
//  Util
//
//  Created by 김동준 on 7/10/26
//

import Foundation

public extension Date {
    static let koreanLocale = Locale(identifier: "ko_KR")
    static let koreanTimeZone = TimeZone(identifier: "Asia/Seoul") ?? .current

    static var koreanCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = koreanLocale
        calendar.timeZone = koreanTimeZone
        return calendar
    }

    static func fixedDateForHourMinTime(
        hour: Int,
        minute: Int,
        calendar: Calendar = koreanCalendar
    ) -> Date {
        // Date cannot represent time alone, so use a fixed date for time picker values.
        calendar.date(
            from: DateComponents(year: 2000, month: 1, day: 1, hour: hour, minute: minute)
        ) ?? Date()
    }

    func startOfDay(calendar: Calendar = Date.koreanCalendar) -> Date {
        calendar.startOfDay(for: self)
    }

    func day(calendar: Calendar = Date.koreanCalendar) -> Int {
        calendar.component(.day, from: self)
    }

    func toString(
        format: DateFormat = .yyyyMMdd,
        locale: Locale = Date.koreanLocale,
        timeZone: TimeZone = Date.koreanTimeZone
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = format.value

        return formatter.string(from: self)
    }

    func toHourMinTimeString(calendar: Calendar = Date.koreanCalendar) -> String {
        String.toHourMinString(
            hour: calendar.component(.hour, from: self),
            minute: calendar.component(.minute, from: self)
        )
    }

    func toKoreanTimeString(calendar: Calendar = Date.koreanCalendar) -> String {
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let period = hour < 12 ? "오전" : "오후"
        let displayHour = hour % 12 == 0 ? 12 : hour % 12

        return "\(period) \(displayHour):\(String(format: "%02d", minute))"
    }

    func neighboringHours(calendar: Calendar = Date.koreanCalendar) -> [Int] {
        let selectedHour = calendar.component(.hour, from: self)
        return (-2...2).map { (selectedHour + $0 + 24) % 24 }
    }

    func neighboringMinutes(calendar: Calendar = Date.koreanCalendar) -> [Int] {
        let selectedMinute = calendar.component(.minute, from: self)
        return (-2...2).map { (selectedMinute + $0 + 60) % 60 }
    }
}

public extension Date {
    func relativeTimeString(to referenceDate: Date = .now) -> String {
        let interval = max(Int(referenceDate.timeIntervalSince(self)), 0)
        
        if interval < 60 {
            return "방금 전"
        }
        
        let minutes = interval / 60
        if minutes < 60 {
            return "\(minutes)분 전"
        }
        
        let hours = minutes / 60
        if hours < 24 {
            return "\(hours)시간 전"
        }
        
        return "\(hours / 24)일 전"
    }
}
