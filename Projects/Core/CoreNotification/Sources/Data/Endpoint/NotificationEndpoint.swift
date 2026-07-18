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
}
