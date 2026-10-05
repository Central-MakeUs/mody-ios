//
//  FeedRepositoryTests.swift
//  FeedTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreNetworkInterface
import Foundation
import XCTest
@testable import Feed

final class FeedRepositoryTests: XCTestCase {
    func testGetRecordsUsesDateCursorAndMapsOnlyRecordsWithImages() async throws {
        let response = try JSONDecoder().decode(FeedRecordListResponse.self, from: Data(#"""
        {
            "records": [
                {"recordId": 3, "recordType": "EXERCISE", "memberId": 8,
                 "nickname": "테스터", "recordedTime": "09:10:00", "imageUrl": "https://example.com/3",
                 "imageCropRegion": {"x": 0.1, "y": 0.2, "width": 0.7, "height": 0.8}},
                {"recordId": 4, "imageUrl": "   "}
            ],
            "nextCursor": 3, "hasNext": true
        }
        """#.utf8))
        let network = FeedNetworkSpy(result: .success(CoreNetworkResponse(result: response)))

        let page = try await FeedRepository(network: network).getRecords(
            groupId: 7, date: "2026-10-05", cursor: 5, size: 10
        )

        XCTAssertEqual(page.records.map(\.recordId), [3])
        XCTAssertEqual(page.records.first?.recordType, .exercise)
        XCTAssertEqual(page.records.first?.recordedTime, "09:10")
        XCTAssertEqual(page.records.first?.imageCropRegion,
                       .init(x: 0.1, y: 0.2, width: 0.7, height: 0.8))
        XCTAssertEqual(page.nextCursor, 3)
        XCTAssertTrue(page.hasNext)
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/groups/7/records")
        XCTAssertEqual(network.endpoints.first?.method, .GET)
        XCTAssertEqual(network.endpoints.first?.queryParameters, [
            "date": "2026-10-05", "cursor": "5", "size": "10"
        ])
    }

    func testGetRecordsRejectsMissingResult() async {
        let network = FeedNetworkSpy(result: .success(
            CoreNetworkResponse<FeedRecordListResponse>(result: nil)
        ))

        do {
            _ = try await FeedRepository(network: network).getRecords(
                groupId: 7, date: "2026-10-05", cursor: nil, size: 5
            )
            XCTFail("Expected invalid response")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
        XCTAssertNil(network.endpoints.first?.queryParameters["cursor"])
    }

    func testGetActivityCalendarMapsDaysAndBaseDate() async throws {
        let response = try JSONDecoder().decode(FeedActivityCalendarResponse.self, from: Data(#"""
        {
            "weekStartDate": "2026-10-05", "weekEndDate": "2026-10-11",
            "days": [{"date": "2026-10-05", "dayOfWeek": "MONDAY", "hasRecord": true}]
        }
        """#.utf8))
        let network = FeedNetworkSpy(result: .success(CoreNetworkResponse(result: response)))

        let calendar = try await FeedRepository(network: network).getActivityCalendar(
            groupId: 7, baseDate: "2026-10-05"
        )

        XCTAssertEqual(calendar.weekStartDate, "2026-10-05")
        XCTAssertEqual(calendar.days.first?.hasRecord, true)
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/groups/7/activities/calendar")
        XCTAssertEqual(network.endpoints.first?.queryParameters, ["baseDate": "2026-10-05"])
    }

    func testPostRecordEncodesMealAndCropRegion() async throws {
        let network = FeedNetworkSpy(result: .success(
            CoreNetworkResponse(result: CoreNetworkEmptyResponse())
        ))
        let request = FeedRecordCreateRequest(
            recordType: .meal, imageKey: "image-key", mealTime: "09:10", menu: "식사",
            imageCropRegion: .init(x: 0.1, y: 0.2, width: 0.7, height: 0.8)
        )

        try await FeedRepository(network: network).postRecord(request)

        XCTAssertEqual(network.endpoints.first?.path, "api/v1/records")
        XCTAssertEqual(network.endpoints.first?.method, .POST)
        XCTAssertEqual(network.endpoints.first?.bodyParameters as? FeedRecordCreateBody,
                       FeedRecordCreateBody(
                        recordType: "MEAL", imageKey: "image-key", mealTime: "09:10",
                        menu: "식사", exerciseDurationHours: nil, exerciseDurationMinutes: nil,
                        exerciseName: nil,
                        imageCropRegion: .init(x: 0.1, y: 0.2, width: 0.7, height: 0.8)
                       ))
    }

    func testReportAndDeleteUseRecordEndpoints() async throws {
        let network = FeedNetworkSpy(result: .success(
            CoreNetworkResponse(result: CoreNetworkEmptyResponse())
        ))
        let repository = FeedRepository(network: network)

        try await repository.postRecordReport(groupId: 7, recordId: 3)
        try await repository.deleteRecord(recordId: 3)

        XCTAssertEqual(network.endpoints.map(\.path), [
            "api/v1/groups/7/records/3/report", "api/v1/records/3"
        ])
        XCTAssertEqual(network.endpoints.map(\.method), [.POST, .DELETE])
    }

    func testWriteRejectsExplicitFailure() async {
        let network = FeedNetworkSpy(result: .success(
            CoreNetworkResponse(isSuccess: false, result: CoreNetworkEmptyResponse())
        ))

        do {
            try await FeedRepository(network: network).deleteRecord(recordId: 3)
            XCTFail("Expected invalid response")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }
}
