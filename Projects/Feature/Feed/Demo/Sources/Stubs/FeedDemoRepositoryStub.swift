//
//  FeedDemoRepositoryStub.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import Feed
import FeedTesting
import Foundation

actor FeedDemoRepositoryStub: FeedRepositoryProtocol {
    private let scenario: FeedDemoScenario
    private var records: [FeedRecord]

    init(scenario: FeedDemoScenario) {
        self.scenario = scenario
        self.records = Self.makeRecords()
    }

    func getActivityCalendar(groupId: Int, baseDate: String) async throws -> FeedActivityCalendarModel {
        try await Task.sleep(for: .milliseconds(500))
        let today = FeedDateFixture.today()
        return FeedActivityCalendarModel(
            weekStartDate: baseDate,
            weekEndDate: today,
            days: [FeedActivityDayModel(date: today, dayOfWeek: "", hasRecord: scenario != .emptyFeed)]
        )
    }

    func getRecords(groupId: Int, date: String, cursor: Int?, size: Int) async throws -> FeedRecordPage {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .feedFailure { throw NetworkError.invalidResponse }
        guard scenario != .emptyFeed, date == FeedDateFixture.today() else {
            return FeedRecordPage(records: [], nextCursor: nil, hasNext: false)
        }

        let groupRecords = records.filter { groupId == 1 || $0.memberId != 100 }
        let start = cursor.flatMap { value in groupRecords.firstIndex { $0.recordId == value }.map { $0 + 1 } } ?? 0
        let end = min(start + size, groupRecords.count)
        let page = Array(groupRecords[start..<end])
        return FeedRecordPage(
            records: page,
            nextCursor: end < groupRecords.count ? page.last?.recordId : nil,
            hasNext: end < groupRecords.count
        )
    }

    func postRecord(_ request: FeedRecordCreateRequest) async throws {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .createFailure { throw NetworkError.invalidResponse }
        records.insert(
            FeedRecord(
                recordId: (records.first?.recordId ?? 0) + 1,
                recordType: request.recordType == .meal ? .meal : .exercise,
                memberId: 100,
                nickname: "내 기록",
                profileImageUrl: nil,
                recordedTime: request.mealTime ?? "12:00",
                menu: request.menu ?? "",
                exerciseDurationMinutes: (request.exerciseDurationHours ?? 0) * 60 + (request.exerciseDurationMinutes ?? 0),
                exerciseName: request.exerciseName ?? "",
                imageUrl: "https://feed.demo/\(request.recordType == .meal ? "meal" : "exercise")/created",
                imageCropRegion: nil,
                recordingStreakDays: 1
            ),
            at: 0
        )
    }

    func postRecordReport(groupId: Int, recordId: Int) async throws {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .reportFailure { throw NetworkError.invalidResponse }
    }

    func deleteRecord(recordId: Int) async throws {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .deleteFailure { throw NetworkError.invalidResponse }
        records.removeAll { $0.recordId == recordId }
    }
}

private extension FeedDemoRepositoryStub {
    static func makeRecords() -> [FeedRecord] {
        (0..<8).map { index in
            let isOwn = index.isMultiple(of: 2)
            return FeedRecord(
                recordId: 800 - index,
                recordType: isOwn ? .meal : .exercise,
                memberId: isOwn ? 100 : 200,
                nickname: isOwn ? "내 기록" : "다른 멤버",
                profileImageUrl: nil,
                recordedTime: "12:00",
                menu: isOwn ? "점심 식사" : "",
                exerciseDurationMinutes: isOwn ? 0 : 40,
                exerciseName: isOwn ? "" : "걷기",
                imageUrl: "https://feed.demo/\(isOwn ? "meal" : "exercise")/\(800 - index)",
                imageCropRegion: nil,
                recordingStreakDays: index + 1
            )
        }
    }

}
