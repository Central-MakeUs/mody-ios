//
//  MyPageEndpoint.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import CoreNetworkInterface

enum MyPageEndpoint {
    static func getMyPageProfile() -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/mypage/profile",
            method: .GET
        )
    }

    static func patchMyPageProfile(
        request: MyPageProfileUpdateRequest
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/mypage/profile",
            method: .PATCH,
            bodyParameters: request
        )
    }

    static func getWeightHistory() -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/mypage/weights",
            method: .GET
        )
    }

    static func postWeight(request: WeightRecordRequest) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/mypage/weights",
            method: .POST,
            bodyParameters: request
        )
    }

    static func getNotificationSettings() -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/mypage/notification-settings",
            method: .GET
        )
    }

    static func patchNotificationSettings(
        request: NotificationSettingRequest
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/mypage/notification-settings",
            method: .PATCH,
            bodyParameters: request
        )
    }
}
