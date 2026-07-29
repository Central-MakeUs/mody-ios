//
//  MyPageNotificationSettingsRoute.swift
//  MyPageInterface
//
//  Created by 김동준 on 7/16/26.
//

public enum MyPageNotificationSettingsRoute: Equatable {
    case back
}

@MainActor
public protocol MyPageNotificationSettingsRouter: AnyObject {
    func route(from route: MyPageNotificationSettingsRoute)
}
