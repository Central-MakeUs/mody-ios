//
//  SplashRouterSpy.swift
//  SplashTests
//
//  Created by 김동준 on 9/29/26.
//

import SplashInterface

@MainActor
final class SplashRouterSpy {
    private(set) var routes: [SplashRoute] = []

    func route(to route: SplashRoute) {
        routes.append(route)
    }
}
