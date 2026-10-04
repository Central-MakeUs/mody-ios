//
//  SplashDemoRouter.swift
//  SplashDemo
//
//  Created by 김동준 on 8/21/26.
//

import SplashInterface

@MainActor
final class SplashDemoRouter: SplashRouter {
    private let onRoute: (SplashRoute) -> Void

    init(onRoute: @escaping (SplashRoute) -> Void) {
        self.onRoute = onRoute
    }

    func route(from route: SplashRoute) {
        onRoute(route)
    }
}
