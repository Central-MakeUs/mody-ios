//
//  NotificationListResponse.swift
//  CoreNotification
//
//  Created by 김동준 on 7/23/26.
//

import CoreNotificationInterface

struct NotificationListResponse: Decodable {
    let notifications: [NotificationItemResponse]?
    let nextCursor: Int?
    let hasNext: Bool?
}

struct NotificationItemResponse: Decodable {
    let notificationId: Int?
    let type: String?
    let title: String?
    let description: String?
    let link: String?
    let createdAt: String?
    let read: Bool?
}

extension NotificationListResponse {
    func toDomain() -> NotificationPage {
        NotificationPage(
            notifications: (notifications ?? []).compactMap { $0.toDomain() },
            nextCursor: nextCursor,
            hasNext: hasNext ?? false
        )
    }
}

private extension NotificationItemResponse {
    func toDomain() -> NotificationItem? {
        guard let type,
              let notificationType = NotificationType(rawValue: type) else {
            return nil
        }

        return NotificationItem(
            notificationId: notificationId ?? -1,
            type: notificationType,
            title: title ?? "",
            description: description ?? "",
            link: link ?? "",
            createdAt: createdAt ?? "",
            isRead: read ?? false
        )
    }
}
