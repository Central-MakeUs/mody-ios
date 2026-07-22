//
//  FeedRepositoryProtocol.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

public protocol FeedRepositoryProtocol {
    func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage
}
