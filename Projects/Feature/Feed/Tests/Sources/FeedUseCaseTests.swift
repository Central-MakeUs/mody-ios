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
}

private extension FeedUseCaseTests {
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

    func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage {
        fatalError("Not used in these tests")
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
}
