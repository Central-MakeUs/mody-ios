//
//  FeedActivityCalendarModel.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

public struct FeedActivityCalendarModel: Equatable {
    public let weekStartDate: String
    public let weekEndDate: String
    public let days: [FeedActivityDayModel]

    public init(
        weekStartDate: String,
        weekEndDate: String,
        days: [FeedActivityDayModel]
    ) {
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.days = days
    }
}

public struct FeedActivityDayModel: Equatable {
    public let date: String
    public let dayOfWeek: String
    public let hasRecord: Bool

    public init(
        date: String,
        dayOfWeek: String,
        hasRecord: Bool
    ) {
        self.date = date
        self.dayOfWeek = dayOfWeek
        self.hasRecord = hasRecord
    }
}
