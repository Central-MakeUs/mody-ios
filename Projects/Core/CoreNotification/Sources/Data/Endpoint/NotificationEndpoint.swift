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

    static func deleteFCMToken(
        _ request: PushTokenDisableRequest
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/notifications/push-token",
            method: .DELETE,
            bodyParameters: request
        )
    }
}
