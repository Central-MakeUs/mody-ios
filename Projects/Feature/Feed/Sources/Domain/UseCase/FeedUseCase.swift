//
//  FeedUseCase.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

public struct FeedUseCase: FeedUseCaseProtocol {
    private let feedRepository: FeedRepositoryProtocol

    public init(feedRepository: FeedRepositoryProtocol) {
        self.feedRepository = feedRepository
    }

    public func fetchActivityCalendar(groupId: Int, baseDate: String) async throws -> FeedActivityCalendarModel {
        try await feedRepository.getActivityCalendar(
            groupId: groupId,
            baseDate: baseDate
        )
    }
}
