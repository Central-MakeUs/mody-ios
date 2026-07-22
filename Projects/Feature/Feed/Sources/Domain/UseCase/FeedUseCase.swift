//
//  FeedUseCase.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

public struct FeedUseCase {
    private let feedRepository: FeedRepositoryProtocol

    public init(feedRepository: FeedRepositoryProtocol) {
        self.feedRepository = feedRepository
    }

    public func fetchFeedRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int = 5
    ) async throws -> FeedRecordPage {
        try await feedRepository.getRecords(
            groupId: groupId,
            date: date,
            cursor: cursor,
            size: size
        )
    }

    public func createRecord(_ request: FeedRecordCreateRequest) async throws {
        try await feedRepository.postRecord(request)
    }
}
