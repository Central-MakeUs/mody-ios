//
//  NotificationPage.swift
//  CoreNotificationInterface
//
//  Created by 김동준 on 7/23/26.
//

public struct NotificationPage: Equatable {
    public let notifications: [NotificationItem]
    public let nextCursor: Int?
    public let hasNext: Bool

    public init(
        notifications: [NotificationItem],
        nextCursor: Int?,
        hasNext: Bool
    ) {
        self.notifications = notifications
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}
