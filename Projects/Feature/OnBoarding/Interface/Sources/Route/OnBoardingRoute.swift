//
//  OnBoardingRoute.swift
//  OnBoardingInterface
//
//  Created by 김동준 on 6/25/26
//

public enum OnBoardingRoute: Equatable {
    case routeToGroupParticipate
}

@MainActor
public protocol OnBoardingRouter: AnyObject {
    func route(from route: OnBoardingRoute)
}
