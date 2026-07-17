//
//  MyPageRoute.swift
//  MyPageInterface
//
//  Created by 김동준 on 6/30/26
//

import CommonDomain
import Foundation

public enum MyPageRoute: Equatable {
    case routeToProfile(profileImageURL: URL?, defaultAvatar: DefaultAvatar)
    case routeToNotificationSettings
    case routeToGroupSettings
    case routeToHealthDataSettings
}

@MainActor
public protocol MyPageRouter: AnyObject {
    func route(from route: MyPageRoute)
}
