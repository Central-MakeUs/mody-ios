//
//  FeedRepositoryProtocol.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

public protocol FeedRepositoryProtocol {
    func getActivityCalendar(groupId: Int, baseDate: String) async throws -> FeedActivityCalendarModel
    func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage

    func postRecord(_ request: FeedRecordCreateRequest) async throws
    func postRecordReport(groupId: Int, recordId: Int) async throws
    func deleteRecord(recordId: Int) async throws
}
