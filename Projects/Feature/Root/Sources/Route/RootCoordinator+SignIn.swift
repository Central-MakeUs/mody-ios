//
//  RootCoordinator+SignIn.swift
//  Root
//
//  Created by 김동준 on 6/25/26.
//

import SignInInterface

extension RootCoordinator: SignInRouter {
    public func route(from route: SignInRoute) {
        switch route {
        case .routeToMain:
            delegate?.didFinishAuthentication(self)
        case .routeToOnBoarding:
            showOnBoarding()
        case .routeToParticipateGroup:
            showModyGroup()
        case .routeToModyGroup:
            showModyGroup()
        }
    }
}
