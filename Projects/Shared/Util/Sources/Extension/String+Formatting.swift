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
}
