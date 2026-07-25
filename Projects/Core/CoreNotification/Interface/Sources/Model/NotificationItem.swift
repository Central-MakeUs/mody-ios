//
//  NotificationItem.swift
//  CoreNotificationInterface
//
//  Created by 김동준 on 7/23/26.
//

public struct NotificationItem: Equatable {
    public let notificationId: Int
    public let type: NotificationType
    public let title: String
    public let description: String
    public let link: String
    public let createdAt: String
    public let isRead: Bool

    public init(
        notificationId: Int,
        type: NotificationType,
        title: String,
        description: String,
        link: String,
        createdAt: String,
        isRead: Bool
    ) {
        self.notificationId = notificationId
        self.type = type
        self.title = title
        self.description = description
        self.link = link
        self.createdAt = createdAt
        self.isRead = isRead
    }
}
