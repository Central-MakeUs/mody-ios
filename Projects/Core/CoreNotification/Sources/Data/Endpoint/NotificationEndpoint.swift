//
//  NotificationEndpoint.swift
//  CoreNotification
//
//  Created by 김동준 on 7/18/26.
//

import CoreNetworkInterface

enum NotificationEndpoint {
    static func postPushFCMToken(
        _ request: PushTokenRegisterRequest
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/notifications/push-token",
            method: .POST,
            bodyParameters: request
        )
    }
    
    static func getNotifications(cursor: Int?, size: Int, allRead: Bool) -> CoreNetworkEndpoint {
        var queryParameters = [
            "size": String(size),
            "allRead": String(allRead)
        ]

        if let cursor {
            queryParameters["cursor"] = String(cursor)
        }

        return CoreNetworkEndpoint(
            path: "api/v1/notifications",
            method: .GET,
            queryParameters: queryParameters
        )
    }

    static func getUnreadExists() -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/notifications/unread-exists",
            method: .GET
        )
    }
}
