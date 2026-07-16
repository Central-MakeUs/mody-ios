//
//  MyPageProfileRoute.swift
//  MyPageInterface
//
//  Created by 김동준 on 7/17/26
//

public enum MyPageProfileRoute: Equatable {
    case back
    case routeToSignIn
}

@MainActor
public protocol MyPageProfileRouter: AnyObject {
    func route(from route: MyPageProfileRoute)
}
