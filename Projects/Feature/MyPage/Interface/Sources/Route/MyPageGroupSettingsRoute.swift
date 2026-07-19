//
//  MyPageGroupSettingsRoute.swift
//  MyPageInterface
//
//  Created by 김동준 on 7/16/26.
//

public enum MyPageGroupSettingsRoute: Equatable {
    case back
    case routeToGroupParticipate
}

@MainActor
public protocol MyPageGroupSettingsRouter: AnyObject {
    func route(from route: MyPageGroupSettingsRoute)
}
