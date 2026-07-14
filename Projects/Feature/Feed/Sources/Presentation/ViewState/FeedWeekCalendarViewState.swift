//
//  FeedWeekCalendarViewState.swift
//  Feed
//
//  Created by 김동준 on 7/14/26.
//

struct FeedWeekCalendarViewState: Equatable {
    let calendarTitle: String
    let calendarDates: [FeedWeekCalendarModel]
    let canMovePreviousWeek: Bool
    let canMoveNextWeek: Bool
    let todayDate: String
    let selectedDate: String
}

extension FeedReactor.State {
    var weekCalendarViewState: FeedWeekCalendarViewState {
        FeedWeekCalendarViewState(
            calendarTitle: calendarTitle,
            calendarDates: calendarDates,
            canMovePreviousWeek: canMovePreviousWeek,
            canMoveNextWeek: canMoveNextWeek,
            todayDate: todayDate,
            selectedDate: selectedDate
        )
    }
}
