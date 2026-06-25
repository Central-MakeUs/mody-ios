//
//  SplashRoute.swift
//  SplashInterface
//
//  Created by 김동준 on 6/25/26
//

public enum SplashRoute: Equatable {
    case routeToMain
    case routeToSignIn
}

@MainActor
public protocol SplashRouter: AnyObject {
    func route(from route: SplashRoute)
}
