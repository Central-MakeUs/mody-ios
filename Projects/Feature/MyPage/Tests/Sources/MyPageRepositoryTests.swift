//
//  MyPageRepositoryTests.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreNetworkInterface
import Foundation
import XCTest
@testable import MyPage

final class MyPageRepositoryTests: XCTestCase {
    func testProfileResponseMappingAndEndpoint() async throws {
        let network = MyPageNetworkSpy()
        network.json = #"{"result":{"loginType":"APPLE","name":"모디","birthDate":"2000-01-02"}}"#
        let profile = try await MyPageRepository(network: network).getMyPageProfile()
        XCTAssertEqual(profile, MyPageProfile(socialLoginType: .apple, name: "모디", birthDate: "2000-01-02"))
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/mypage/profile")
        XCTAssertEqual(network.endpoints.first?.method, .GET)
        XCTAssertEqual(network.endpoints.first?.requiresAuthorization, true)
    }

    func testMissingProfileFieldsUseDefaults() async throws {
        let network = MyPageNetworkSpy()
        network.json = #"{"result":{}}"#
        let profile = try await MyPageRepository(network: network).getMyPageProfile()
        XCTAssertEqual(profile, MyPageProfile(socialLoginType: .kakao, name: "-", birthDate: ""))
    }

    func testWeightMappingAndMissingFields() async throws {
        for (json, expected) in [
            (#"{"result":{"startWeightKg":80,"currentWeightKg":72,"targetWeightKg":65}}"#, MyPageFixture.weight),
            (#"{"result":{}}"#, WeightRecord(startWeightKg: 0, currentWeightKg: 0, targetWeightKg: 0))
        ] {
            let network = MyPageNetworkSpy()
            network.json = json
            let weight = try await MyPageRepository(network: network).getWeightRecord()
            XCTAssertEqual(weight, expected)
            XCTAssertEqual(network.endpoints.first?.path, "api/v1/mypage/weights")
            XCTAssertEqual(network.endpoints.first?.method, .GET)
        }
    }

    func testProfileAndWeightMutationBodies() async throws {
        let network = MyPageNetworkSpy()
        let repository = MyPageRepository(network: network)
        let request = MyPageProfileUpdateRequest(nickname: "모디", birthDate: "2000-01-02", imageKey: "images/key")
        try await repository.updateMyPageProfile(request)
        try await repository.postRecordWeight(recordedOn: "2026-10-05", weightKg: 71.5)
        XCTAssertEqual(network.endpoints.count, 2)
        XCTAssertEqual(network.endpoints[0].path, "api/v1/mypage/profile")
        XCTAssertEqual(network.endpoints[0].method, .PATCH)
        XCTAssertEqual(network.endpoints[0].bodyParameters as? MyPageProfileUpdateRequest, request)
        XCTAssertEqual(network.endpoints[1].path, "api/v1/mypage/weights")
        XCTAssertEqual(network.endpoints[1].method, .POST)
        let body = try jsonBody(network.endpoints[1])
        XCTAssertEqual(body["recordedOn"] as? String, "2026-10-05")
        XCTAssertEqual(body["weightKg"] as? Double, 71.5)
    }

    func testNotificationMappingAndMutationCodingKeys() async throws {
        let network = MyPageNetworkSpy()
        network.json = #"{"result":{"recordReminderEnabled":true,"commentNotificationEnabled":true,"challengeNotificationEnabled":false,"mealSchedules":[{"mealType":"BREAKFAST","time":"08:00","skipped":false}],"exerciseSchedules":[{"dayOfWeek":"MONDAY","time":"09:00"}]}}"#
        let repository = MyPageNotificationSettingRepository(network: network)
        let fetched = try await repository.getNotificationSettings()
        let updated = try await repository.patchNotificationSettings(MyPageFixture.settings)
        XCTAssertEqual(fetched, MyPageFixture.settings)
        XCTAssertEqual(updated, MyPageFixture.settings)
        XCTAssertEqual(network.endpoints.map(\.path), Array(repeating: "api/v1/mypage/notification-settings", count: 2))
        XCTAssertEqual(network.endpoints.map(\.method), [.GET, .PATCH])
        let body = try jsonBody(network.endpoints[1])
        XCTAssertEqual(body["recordReminderEnabled"] as? Bool, true)
        XCTAssertEqual(body["commentNotificationEnabled"] as? Bool, true)
        XCTAssertEqual(body["challengeNotificationEnabled"] as? Bool, false)
        XCTAssertNil(body["mealAndExerciseEnabled"])
    }

    func testEmptyNotificationFieldsAndScheduleBody() async throws {
        let network = MyPageNetworkSpy()
        network.json = #"{"result":{}}"#
        let repository = MyPageNotificationSettingRepository(network: network)
        let settings = try await repository.getNotificationSettings()
        XCTAssertEqual(settings, NotificationSettingState())
        let meals = [MealScheduleRequest(mealType: .breakfast, time: nil, skipped: true)]
        try await repository.putSchedules(mealSchedules: meals, exerciseSchedules: MyPageFixture.settings.exerciseSchedules)
        let endpoint = try XCTUnwrap(network.endpoints.last)
        XCTAssertEqual(endpoint.path, "api/v1/mypage/schedules")
        XCTAssertEqual(endpoint.method, .PUT)
        let body = try jsonBody(endpoint)
        let meal = try XCTUnwrap((body["mealSchedules"] as? [[String: Any]])?.first)
        XCTAssertTrue(meal["time"] is NSNull)
        XCTAssertEqual(meal["skipped"] as? Bool, true)
        let exercise = try XCTUnwrap((body["exerciseSchedules"] as? [[String: Any]])?.first)
        XCTAssertEqual(exercise["dayOfWeek"] as? String, "MONDAY")
        XCTAssertEqual(exercise["time"] as? String, "09:00")
    }

    func testMissingResultsAndNetworkErrorsAreNotSwallowed() async {
        let network = MyPageNetworkSpy()
        let profile = MyPageRepository(network: network)
        let notification = MyPageNotificationSettingRepository(network: network)
        let operations: [() async throws -> Void] = [
            { _ = try await profile.getMyPageProfile() },
            { _ = try await profile.getWeightRecord() },
            { _ = try await notification.getNotificationSettings() },
            { _ = try await notification.patchNotificationSettings(MyPageFixture.settings) }
        ]
        for error in [NetworkError.invalidResponse, .networkUnavailable] {
            network.error = error == .networkUnavailable ? error : nil
            for operation in operations {
                do { try await operation(); XCTFail("Expected failure") }
                catch let received { XCTAssertEqual(received as? NetworkError, error) }
            }
        }
    }

    private func jsonBody(_ endpoint: CoreNetworkEndpoint) throws -> [String: Any] {
        let body = try XCTUnwrap(endpoint.bodyParameters)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(body)) as? [String: Any])
    }
}
