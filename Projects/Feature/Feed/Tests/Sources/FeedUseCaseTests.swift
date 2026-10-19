//
//  FeedUseCaseTests.swift
//  FeedTests
//
//  Created by 김동준 on 10/5/26.
//

import Foundation
import FeedInterface
import XCTest
@testable import Feed

final class FeedUseCaseTests: XCTestCase {
    func testInitialPageDisablesPaginationWithoutCursor() async throws {
        let repository = FeedRepositorySpy()
        repository.pages = [.init(records: [record(1)], nextCursor: nil, hasNext: true)]

        let page = try await FeedUseCase(feedRepository: repository).fetchFeedRecords(
            groupId: 7, date: "2026-10-05", cursor: nil
        )

        XCTAssertEqual(page.records.map(\.recordId), [1])
        XCTAssertFalse(page.hasNext)
        XCTAssertEqual(repository.recordsRequests, [
            .init(groupId: 7, date: "2026-10-05", cursor: nil, size: 5)
        ])
    }

    func testNextPageAppendsUniqueRecordsAndStopsRepeatedCursor() async throws {
        let repository = FeedRepositorySpy()
        repository.pages = [.init(records: [record(2), record(3), record(3)], nextCursor: 2, hasNext: true)]
        let currentPage = FeedRecordPage(records: [record(1), record(2)], nextCursor: 2, hasNext: true)

        let page = try await FeedUseCase(feedRepository: repository).fetchNextFeedRecords(
            groupId: 7, date: "2026-10-05", currentPage: currentPage, size: 10
        )

        XCTAssertEqual(page.records.map(\.recordId), [1, 2, 3])
        XCTAssertFalse(page.hasNext)
        XCTAssertEqual(repository.recordsRequests, [
            .init(groupId: 7, date: "2026-10-05", cursor: 2, size: 10)
        ])
    }

    func testNextPageWithoutCursorDoesNotCallRepository() async throws {
        let repository = FeedRepositorySpy()
        let currentPage = FeedRecordPage(records: [record(1)], nextCursor: nil, hasNext: true)

        let page = try await FeedUseCase(feedRepository: repository).fetchNextFeedRecords(
            groupId: 7, date: "2026-10-05", currentPage: currentPage
        )

        XCTAssertEqual(page, currentPage)
        XCTAssertTrue(repository.recordsRequests.isEmpty)
    }

    func testRefreshPrependsOnlyNewRecordsAndPreservesExistingCursor() async throws {
        let repository = FeedRepositorySpy()
        repository.pages = [.init(records: [record(4), record(3), record(3), record(2)], nextCursor: 4, hasNext: true)]
        let currentPage = FeedRecordPage(records: [record(3), record(2)], nextCursor: 2, hasNext: true)

        let page = try await FeedUseCase(feedRepository: repository).refreshLatestFeedRecords(
            groupId: 7, date: "2026-10-05", currentPage: currentPage
        )

        XCTAssertEqual(page.records.map(\.recordId), [4, 3, 2])
        XCTAssertEqual(page.nextCursor, 2)
        XCTAssertTrue(page.hasNext)
        XCTAssertEqual(repository.recordsRequests.count, 1)
        XCTAssertNil(repository.recordsRequests.first?.cursor)
    }

    func testMealRequestTrimsMenuAndClampsCropRegion() {
        let useCase = FeedUseCase(feedRepository: FeedRepositorySpy())
        let calendar = Calendar(identifier: .gregorian)
        let mealTime = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5, hour: 9, minute: 7))!

        let request = useCase.makeRecordCreationRequest(
            imageKey: "image-key", recordType: .meal, mealTime: mealTime,
            calendar: calendar, mealMenu: "  아침 식사 \n", exerciseType: nil,
            customExerciseName: "", exerciseDurationHours: 0, exerciseDurationMinutes: 0,
            normalizedImageCropRegion: CGRect(x: -0.1, y: 0.25, width: 1.2, height: 0.5)
        )

        XCTAssertEqual(request?.recordType, .meal)
        XCTAssertEqual(request?.mealTime, "09:07")
        XCTAssertEqual(request?.menu, "아침 식사")
        XCTAssertEqual(request?.imageCropRegion, .init(x: 0, y: 0.25, width: 1, height: 0.5))
    }

    func testExerciseRequestUsesCustomNameAndRejectsMissingTypeOrInvalidCrop() {
        let useCase = FeedUseCase(feedRepository: FeedRepositorySpy())
        let arguments = (
            imageKey: "image-key", recordType: FeedRecordType.exercise, mealTime: Date(),
            calendar: Calendar(identifier: .gregorian), mealMenu: "", exerciseDurationHours: 1,
            exerciseDurationMinutes: 30
        )

        let request = useCase.makeRecordCreationRequest(
            imageKey: arguments.imageKey, recordType: arguments.recordType,
            mealTime: arguments.mealTime, calendar: arguments.calendar, mealMenu: arguments.mealMenu,
            exerciseType: .custom, customExerciseName: "  클라이밍  ",
            exerciseDurationHours: arguments.exerciseDurationHours,
            exerciseDurationMinutes: arguments.exerciseDurationMinutes,
            normalizedImageCropRegion: CGRect(x: 0, y: 0, width: 1, height: 1)
        )

        XCTAssertEqual(request?.recordType, .exercise)
        XCTAssertEqual(request?.exerciseName, "클라이밍")
        XCTAssertEqual(request?.exerciseDurationHours, 1)
        XCTAssertEqual(request?.exerciseDurationMinutes, 30)
        XCTAssertNil(useCase.makeRecordCreationRequest(
            imageKey: arguments.imageKey, recordType: arguments.recordType,
            mealTime: arguments.mealTime, calendar: arguments.calendar, mealMenu: arguments.mealMenu,
            exerciseType: nil, customExerciseName: "",
            exerciseDurationHours: arguments.exerciseDurationHours,
            exerciseDurationMinutes: arguments.exerciseDurationMinutes,
            normalizedImageCropRegion: CGRect(x: 0, y: 0, width: 1, height: 1)
        ))
        XCTAssertNil(useCase.makeRecordCreationRequest(
            imageKey: arguments.imageKey, recordType: arguments.recordType,
            mealTime: arguments.mealTime, calendar: arguments.calendar, mealMenu: arguments.mealMenu,
            exerciseType: .fitness, customExerciseName: "",
            exerciseDurationHours: arguments.exerciseDurationHours,
            exerciseDurationMinutes: arguments.exerciseDurationMinutes,
            normalizedImageCropRegion: CGRect(x: 0, y: 0, width: 0, height: 1)
        ))
    }

    private func record(_ id: Int) -> FeedRecord {
        FeedRecord(
            recordId: id, recordType: .meal, memberId: 1, nickname: "테스터",
            profileImageUrl: nil, recordedTime: "09:00", menu: "식사",
            exerciseDurationMinutes: 0, exerciseName: "", imageUrl: "https://example.com/\(id)",
            imageCropRegion: nil, recordingStreakDays: 1
        )
    }
}
