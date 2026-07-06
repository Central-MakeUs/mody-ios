//
//  RootCoordinator+ModyGroup.swift
//  Root
//
//  Created by 김동준 on 6/26/26
//

import ModyGroupInterface

extension RootCoordinator: ModyGroupRouter {
    public func route(from route: ModyGroupRoute) {
        switch route {
        case .routeToMain:
            delegate?.didFinishAuthentication(self)
        }
    }
}
