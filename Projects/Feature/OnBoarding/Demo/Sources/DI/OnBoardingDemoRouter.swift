//
//  OnBoardingDemoRouter.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import OnBoardingInterface

@MainActor
final class OnBoardingDemoRouter: OnBoardingRouter {
    private let onRoute: (OnBoardingRoute) -> Void

    init(onRoute: @escaping (OnBoardingRoute) -> Void) {
        self.onRoute = onRoute
    }

    func route(from route: OnBoardingRoute) {
        onRoute(route)
    }
}
