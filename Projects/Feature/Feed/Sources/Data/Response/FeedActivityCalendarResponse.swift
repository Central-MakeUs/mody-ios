//
//  FeedActivityCalendarResponse.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

struct FeedActivityCalendarResponse: Decodable, Equatable {
    let weekStartDate: String?
    let weekEndDate: String?
    let days: [FeedActivityDayResponse]?
}

struct FeedActivityDayResponse: Decodable, Equatable {
    let date: String?
    let dayOfWeek: String?
    let hasRecord: Bool?
}

extension FeedActivityCalendarResponse {
    func toDomain() -> FeedActivityCalendarModel {
        FeedActivityCalendarModel(
            weekStartDate: weekStartDate ?? "",
            weekEndDate: weekEndDate ?? "",
            days: (days ?? []).map { $0.toDomain() }
        )
    }
}

private extension FeedActivityDayResponse {
    func toDomain() -> FeedActivityDayModel {
        FeedActivityDayModel(
            date: date ?? "",
            dayOfWeek: dayOfWeek ?? "",
            hasRecord: hasRecord ?? false
        )
    }
}
