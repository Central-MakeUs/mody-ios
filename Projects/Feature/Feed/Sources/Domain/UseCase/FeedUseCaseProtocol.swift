//
//  FeedUseCaseProtocol.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

public protocol FeedUseCaseProtocol {
    func fetchActivityCalendar(groupId: Int, baseDate: String) async throws -> FeedActivityCalendarModel
}
