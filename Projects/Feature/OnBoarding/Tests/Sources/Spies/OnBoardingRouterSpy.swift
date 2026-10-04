//
//  OnBoardingRouterSpy.swift
//  OnBoardingTests
//
//  Created by 김동준 on 10/4/26.
//

import OnBoardingInterface

@MainActor
final class OnBoardingRouterSpy {
    private(set) var routes: [OnBoardingRoute] = []

    func route(_ destination: OnBoardingRoute) {
        routes.append(destination)
    }
}
