//  MyPageDemoNetworkData.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/9/26.
//

import CommonDomain
import CoreNetworkInterface
import CoreNetworkTesting
import Foundation

actor MyPageDemoProfileData {
    private(set) var name = "동준이"

    func response(to endpoint: CoreNetworkEndpoint, scenario: MyPageScenario) async throws -> Data {
        switch (endpoint.method, endpoint.path) {
        case (.GET, "api/v1/mypage/profile"):
            if scenario == .profileLookupFailure { throw NetworkError.networkUnavailable }
            return try CoreNetworkJSONFixture.response(result: ["loginType": "KAKAO", "name": name, "birthDate": "2000-01-01"])
        case (.PATCH, "api/v1/mypage/profile"):
            if scenario == .profileSaveFailure { throw NetworkError.networkUnavailable }
            let body = try CoreNetworkJSONFixture.body(of: endpoint)
            guard let nickname = body["nickname"] as? String else { throw NetworkError.invalidResponse }
            name = nickname
        case (.GET, "api/v1/mypage/weights"):
            if scenario == .weightLookupFailure { throw NetworkError.networkUnavailable }
            return try CoreNetworkJSONFixture.response(result: ["startWeightKg": 56, "currentWeightKg": 53, "targetWeightKg": 50])
        case (.POST, "api/v1/mypage/weights"):
            try await Task.sleep(for: .milliseconds(500))
            if scenario == .weightSaveFailure { throw NetworkError.networkUnavailable }
        case (.GET, "api/v1/mypage/notification-settings"):
            if scenario == .notificationLookupFailure { throw NetworkError.networkUnavailable }
            return try notificationResponse(scenario: scenario)
        case (.PATCH, "api/v1/mypage/notification-settings"):
            try await Task.sleep(for: .milliseconds(500))
            if scenario == .notificationToggleFailure { throw NetworkError.networkUnavailable }
            let body = try CoreNetworkJSONFixture.body(of: endpoint)
            return try notificationResponse(scenario: scenario, toggles: body)
        case (.PUT, "api/v1/mypage/schedules"):
            if scenario == .notificationSaveFailure { throw NetworkError.networkUnavailable }
        default:
            throw URLError(.unsupportedURL)
        }
        return try CoreNetworkJSONFixture.response()
    }

    private func notificationResponse(scenario: MyPageScenario, toggles: [String: Any] = [:]) throws -> Data {
        try CoreNetworkJSONFixture.response(result: [
            "recordReminderEnabled": toggles["recordReminderEnabled"] ?? (scenario != .notificationSaveDisabled),
            "commentNotificationEnabled": toggles["commentNotificationEnabled"] ?? true,
            "challengeNotificationEnabled": toggles["challengeNotificationEnabled"] ?? true,
            "mealSchedules": MealType.allCases.map { ["mealType": $0.rawValue, "time": "09:00", "skipped": false] as [String: Any] },
            "exerciseSchedules": [["dayOfWeek": DayOfWeek.monday.rawValue, "time": "09:00"]]
        ])
    }
}
