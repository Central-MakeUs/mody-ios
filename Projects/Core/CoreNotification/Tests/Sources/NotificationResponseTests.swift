//  NotificationResponseTests.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNotificationInterface
import Foundation
import XCTest

@testable import CoreNotification

final class NotificationResponseTests: XCTestCase {
    func testCompleteListMapsEveryFieldAndPagination() throws {
        let data = try JSONSerialization.data(withJSONObject: NotificationTestFixture.list)

        let response = try JSONDecoder().decode(NotificationListResponse.self, from: data)

        XCTAssertEqual(response.toDomain(), NotificationTestFixture.page)
    }

    func testAllSupportedTypesArePreservedInOrder() throws {
        let types: [(String, NotificationType)] = [
            ("GROUP_MEMBER_JOINED", .groupMemberJoined), ("EXERCISE_REMINDER", .exerciseReminder),
            ("MEAL_REMINDER", .mealReminder), ("COMMENT_CREATED", .commentCreated),
            ("GROUP_RECORD_STREAK_RISK", .groupRecordStreakRisk), ("BUDDY_NUDGE", .buddyNudge),
            ("STEP_CHALLENGE_COMPLETED", .stepChallengeCompleted), ("WEEKLY_CHALLENGE_COMPLETED", .weeklyChallengeCompleted)
        ]
        let data = try JSONSerialization.data(withJSONObject: ["notifications": types.map { ["type": $0.0] }])

        let page = try JSONDecoder().decode(NotificationListResponse.self, from: data).toDomain()

        XCTAssertEqual(page.notifications.map(\.type), types.map { $0.1 })
    }

    func testUnknownAndMissingTypesAreDroppedWhileKnownItemRemains() throws {
        let data = Data(#"{"notifications":[{"type":"NEW_TYPE"},{"type":null},{},{"type":"BUDDY_NUDGE","notificationId":7}]}"#.utf8)

        let page = try JSONDecoder().decode(NotificationListResponse.self, from: data).toDomain()

        XCTAssertEqual(page.notifications.count, 1)
        XCTAssertEqual(page.notifications.first?.notificationId, 7)
        XCTAssertEqual(page.notifications.first?.type, .buddyNudge)
    }

    func testMissingItemFieldsUseDefaults() throws {
        let data = Data(#"{"notifications":[{"type":"MEAL_REMINDER"}]}"#.utf8)

        let page = try JSONDecoder().decode(NotificationListResponse.self, from: data).toDomain()

        XCTAssertEqual(page.notifications, [NotificationItem(
            notificationId: -1, type: .mealReminder, title: "", description: "", link: "", createdAt: "", isRead: false
        )])
    }

    func testMissingAndNullPageFieldsUseEmptyDefaults() throws {
        for json in ["{}", #"{"notifications":null,"nextCursor":null,"hasNext":null}"#] {
            let page = try JSONDecoder().decode(NotificationListResponse.self, from: Data(json.utf8)).toDomain()

            XCTAssertEqual(page, NotificationPage(notifications: [], nextCursor: nil, hasNext: false))
        }
    }

    func testUnreadMappingDefaultsAndBothValues() throws {
        for (json, expected) in [("{}", false), (#"{"hasUnread":null}"#, false),
                                 (#"{"hasUnread":false}"#, false), (#"{"hasUnread":true}"#, true)] {
            let response = try JSONDecoder().decode(NotificationUnReadExistsResponse.self, from: Data(json.utf8))

            XCTAssertEqual(response.toDomain(), expected)
        }
    }

    func testWrongFieldTypesFailDecoding() {
        for json in [#"{"notifications":"invalid"}"#, #"{"notifications":[{"type":"BUDDY_NUDGE","read":"true"}]}"#] {
            XCTAssertThrowsError(try JSONDecoder().decode(NotificationListResponse.self, from: Data(json.utf8)))
        }
        XCTAssertThrowsError(try JSONDecoder().decode(NotificationUnReadExistsResponse.self, from: Data(#"{"hasUnread":"true"}"#.utf8)))
    }
}
