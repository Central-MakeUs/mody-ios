//
//  RootCoordinator+SignUpDone.swift
//  Root
//
//  Created by 김동준 on 6/26/26
//

import SignUpDoneInterface

extension RootCoordinator: SignUpDoneRouter {
    public func route(from route: SignUpDoneRoute) {
        switch route {
        case .routeToMain:
            delegate?.didFinishAuthentication(self)
        }
    }
}
