//
//  RootCoordinator+Splash.swift
//  Root
//
//  Created by 김동준 on 6/25/26
//

import SplashInterface

extension RootCoordinator: SplashRouter {
    public func route(from route: SplashRoute) {
        switch route {
        case .routeToMain:
            delegate?.didFinishAuthentication(self)
        case .routeToSignIn:
            showSignIn()
        case .routeToModyGroup(let showSignUpDoneContents):
            showModyGroup(showSignUpDoneContents: showSignUpDoneContents)
        }
    }
}
