//  NotificationTestFixture.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNotificationInterface
import Foundation

enum NotificationTestFixture {
    static let item = NotificationItem(
        notificationId: 42, type: .buddyNudge, title: "함께 운동해요", description: "친구 알림",
        link: "mody://feed", createdAt: "2026-10-09T09:00:00", isRead: true
    )
    static let page = NotificationPage(notifications: [item], nextCursor: 41, hasNext: true)
    static let list: [String: Any] = [
        "notifications": [[
            "notificationId": 42, "type": "BUDDY_NUDGE", "title": "함께 운동해요",
            "description": "친구 알림", "link": "mody://feed", "createdAt": "2026-10-09T09:00:00", "read": true
        ]],
        "nextCursor": 41, "hasNext": true
    ]
}

enum NotificationTestError: Error, Equatable {
    case expected
    case unexpectedCall
}
