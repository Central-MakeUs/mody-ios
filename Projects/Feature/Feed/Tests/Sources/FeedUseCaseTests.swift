//
//  FeedUseCaseTests.swift
//  FeedTests
//
//  Created by 김동준 on 7/25/26.
//

import Foundation
import XCTest
@testable import Feed

final class FeedUseCaseTests: XCTestCase {
    func testFetchNextFeedRecordsRemovesDuplicatesAndStopsRepeatedCursor() async throws {
        let repository = FeedUseCaseRepositorySpy(
            pages: [
                makePage(
                    recordIDs: [4, 3],
                    nextCursor: 4,
                    hasNext: true
                )
            ]
        )
        let useCase = FeedUseCase(feedRepository: repository)
        let currentPage = makePage(
            recordIDs: [5, 4],
            nextCursor: 4,
            hasNext: true
        )

        let page = try await useCase.fetchNextFeedRecords(
            groupId: 1,
            date: "2026-07-26",
            currentPage: currentPage
        )

        XCTAssertEqual(page.records.map(\.recordId), [5, 4, 3])
        XCTAssertEqual(page.nextCursor, 4)
        XCTAssertFalse(page.hasNext)
        XCTAssertEqual(repository.requestCursors, [4])
    }

    func testRefreshLatestFeedRecordsPrependsNewRecordsAndPreservesCursor() async throws {
        let repository = FeedUseCaseRepositorySpy(
            pages: [
                makePage(
                    recordIDs: [6, 5],
                    nextCursor: 5,
                    hasNext: true
                )
            ]
        )
        let useCase = FeedUseCase(feedRepository: repository)
        let currentPage = makePage(
            recordIDs: [5, 4],
            nextCursor: 4,
            hasNext: true
        )

        let page = try await useCase.refreshLatestFeedRecords(
            groupId: 1,
            date: "2026-07-26",
            currentPage: currentPage
        )

        XCTAssertEqual(page.records.map(\.recordId), [6, 5, 4])
        XCTAssertEqual(page.nextCursor, 4)
        XCTAssertTrue(page.hasNext)
        XCTAssertEqual(repository.requestCursors, [nil])
    }

    func testCreateMealRecordBuildsNormalizedRequest() async throws {
        let repository = FeedUseCaseRepositorySpy()
        let useCase = FeedUseCase(feedRepository: repository)
        let mealTime = makeKoreanDate(hour: 12, minute: 30)
        let request = try XCTUnwrap(useCase.makeRecordCreationRequest(
            imageKey: "meal-image-key",
            recordType: .meal,
            mealTime: mealTime,
            mealMenu: "  닭가슴살 샐러드 \n",
            exerciseType: nil,
            customExerciseName: "",
            exerciseDurationHours: 0,
            exerciseDurationMinutes: 0,
            normalizedImageCropRegion: CGRect(
                x: -0.2,
                y: 0.1,
                width: 1.2,
                height: 0.8
            )
        ))

        try await useCase.createRecord(request)

        XCTAssertEqual(
            repository.createdRequest,
            FeedRecordCreateRequest(
                recordType: .meal,
                imageKey: "meal-image-key",
                mealTime: "12:30",
                menu: "닭가슴살 샐러드",
                imageCropRegion: .init(
                    x: 0,
                    y: 0.1,
                    width: 1,
                    height: 0.8
                )
            )
        )
    }

    func testCreateCustomExerciseRecordUsesTrimmedCustomName() async throws {
        let repository = FeedUseCaseRepositorySpy()
        let useCase = FeedUseCase(feedRepository: repository)
        let request = try XCTUnwrap(useCase.makeRecordCreationRequest(
            imageKey: "exercise-image-key",
            recordType: .exercise,
            mealTime: Date(),
            mealMenu: "",
            exerciseType: .custom,
            customExerciseName: "  계단 오르기  ",
            exerciseDurationHours: 1,
            exerciseDurationMinutes: 20,
            normalizedImageCropRegion: CGRect(
                x: 0.2,
                y: 0.3,
                width: 0.4,
                height: 0.5
            )
        ))

        try await useCase.createRecord(request)

        XCTAssertEqual(
            repository.createdRequest,
            FeedRecordCreateRequest(
                recordType: .exercise,
                imageKey: "exercise-image-key",
                exerciseDurationHours: 1,
                exerciseDurationMinutes: 20,
                exerciseName: "계단 오르기",
                imageCropRegion: .init(
                    x: 0.2,
                    y: 0.3,
                    width: 0.4,
                    height: 0.5
                )
            )
        )
    }

    func testReportRecordForwardsGroupAndRecordIDs() async throws {
        let repository = FeedUseCaseRepositorySpy()
        let useCase = FeedUseCase(feedRepository: repository)

        try await useCase.reportRecord(groupId: 11, recordId: 22)

        XCTAssertEqual(repository.reportedGroupID, 11)
        XCTAssertEqual(repository.reportedRecordID, 22)
    }
}

private extension FeedUseCaseTests {
    func makePage(
        recordIDs: [Int],
        nextCursor: Int?,
        hasNext: Bool
    ) -> FeedRecordPage {
        FeedRecordPage(
            records: recordIDs.map(makeRecord),
            nextCursor: nextCursor,
            hasNext: hasNext
        )
    }

    func makeRecord(recordID: Int) -> FeedRecord {
        FeedRecord(
            recordId: recordID,
            recordType: .meal,
            memberId: 1,
            nickname: "테스터",
            profileImageUrl: nil,
            recordedTime: "12:00",
            menu: "메뉴",
            exerciseDurationMinutes: 0,
            exerciseName: "",
            imageUrl: "https://example.com/\(recordID).jpg",
            imageCropRegion: nil,
            recordingStreakDays: 1
        )
    }

    func makeKoreanDate(hour: Int, minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar.date(
            from: DateComponents(
                year: 2026,
                month: 7,
                day: 25,
                hour: hour,
                minute: minute
            )
        ) ?? Date()
    }
}

private final class FeedUseCaseRepositorySpy: FeedRepositoryProtocol {
    private(set) var createdRequest: FeedRecordCreateRequest?
    private(set) var reportedGroupID: Int?
    private(set) var reportedRecordID: Int?
    private(set) var requestCursors: [Int?] = []
    private var pages: [FeedRecordPage]

    init(pages: [FeedRecordPage] = []) {
        self.pages = pages
    }

    func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage {
        requestCursors.append(cursor)
        return pages.removeFirst()
    }

    func getActivityCalendar(
        groupId: Int,
        baseDate: String
    ) async throws -> FeedActivityCalendarModel {
        fatalError("Not used in these tests")
    }

    func postRecord(_ request: FeedRecordCreateRequest) async throws {
        createdRequest = request
    }

    func postRecordReport(groupId: Int, recordId: Int) async throws {
        reportedGroupID = groupId
        reportedRecordID = recordId
    }

    func deleteRecord(recordId: Int) async throws {}
}
