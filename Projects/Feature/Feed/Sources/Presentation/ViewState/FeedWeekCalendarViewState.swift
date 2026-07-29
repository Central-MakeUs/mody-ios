//
//  FeedWeekCalendarViewState.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

struct FeedWeekCalendarViewState: Equatable {
    var calendarTitle: String
    var calendarDates: [FeedWeekCalendarModel]
    var canMovePreviousWeek: Bool
    var canMoveNextWeek: Bool
    var todayDate: String
    var selectedDate: String
}
