//
//  MyPageHealthDataSettingsRoute.swift
//  MyPageInterface
//
//  Created by 김동준 on 7/16/26.
//

public enum MyPageHealthDataSettingsRoute: Equatable {
    case back
}

@MainActor
public protocol MyPageHealthDataSettingsRouter: AnyObject {
    func route(from route: MyPageHealthDataSettingsRoute)
}
