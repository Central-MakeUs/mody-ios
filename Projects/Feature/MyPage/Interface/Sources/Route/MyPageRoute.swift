//
//  MyPageRoute.swift
//  MyPageInterface
//
//  Created by 김동준 on 6/30/26
//

public enum MyPageRoute: Equatable {
    case routeToProfile
}

@MainActor
public protocol MyPageRouter: AnyObject {
    func route(from route: MyPageRoute)
}

public enum MyPageProfileRoute: Equatable {
    case back
    case routeToSignIn
}

@MainActor
public protocol MyPageProfileRouter: AnyObject {
    func route(from route: MyPageProfileRoute)
}
