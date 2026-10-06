//
//  FeedRepositorySpy.swift
//  FeedTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
@testable import Feed

final class FeedRepositorySpy: FeedRepositoryProtocol {
    struct RecordsRequest: Equatable {
        let groupId: Int
        let date: String
        let cursor: Int?
        let size: Int
    }

    var pages: [FeedRecordPage] = []
    private(set) var recordsRequests: [RecordsRequest] = []
    private(set) var createdRecords: [FeedRecordCreateRequest] = []

    func getActivityCalendar(groupId: Int, baseDate: String) async throws -> FeedActivityCalendarModel {
        FeedActivityCalendarModel(weekStartDate: "", weekEndDate: "", days: [])
    }

    func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage {
        recordsRequests.append(.init(groupId: groupId, date: date, cursor: cursor, size: size))
        guard !pages.isEmpty else { throw NetworkError.invalidResponse }
        return pages.removeFirst()
    }

    func postRecord(_ request: FeedRecordCreateRequest) async throws {
        createdRecords.append(request)
    }

    func postRecordReport(groupId: Int, recordId: Int) async throws {}

    func deleteRecord(recordId: Int) async throws {}
}
