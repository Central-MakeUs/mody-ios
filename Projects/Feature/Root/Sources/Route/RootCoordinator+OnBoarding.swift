//
//  RootCoordinator+OnBoarding.swift
//  Root
//
//  Created by 김동준 on 6/26/26
//

import OnBoardingInterface

extension RootCoordinator: OnBoardingRouter {
    public func route(from route: OnBoardingRoute) {
        switch route {
        case .routeToGroupParticipate:
            showModyGroup()
        }
    }
}
