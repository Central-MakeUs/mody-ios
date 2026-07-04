//
//  SignInRoute.swift
//  SignInInterface
//
//  Created by 김동준 on 6/25/26
//

public enum SignInRoute: Equatable {
    case routeToMain
    case routeToOnBoarding
    case routeToSignUpDone
    case routeToParticipateGroup
}

@MainActor
public protocol SignInRouter: AnyObject {
    func route(from route: SignInRoute)
}
