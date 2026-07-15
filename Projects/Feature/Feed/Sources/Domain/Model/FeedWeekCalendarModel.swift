//
//  FeedWeekCalendarModel.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

import CommonDomain

public struct FeedWeekCalendarModel: Equatable {
    public let date: String
    public let dayOfWeek: DayOfWeek
    public let hasRecord: Bool

    public init(
        date: String,
        dayOfWeek: DayOfWeek,
        hasRecord: Bool
    ) {
        self.date = date
        self.dayOfWeek = dayOfWeek
        self.hasRecord = hasRecord
    }
}
