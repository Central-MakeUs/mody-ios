//
//  PushTokenRegisterRequest.swift
//  CoreNotification
//
//  Created by 김동준 on 7/18/26.
//

struct PushTokenRegisterRequest: Encodable {
    let deviceId: String?
    let platform: String
    let fcmToken: String

    init(
        deviceId: String?,
        fcmToken: String
    ) {
        self.deviceId = deviceId
        self.platform = "IOS"
        self.fcmToken = fcmToken
    }
}
