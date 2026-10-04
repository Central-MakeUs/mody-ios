//
//  SignInRouterSpy.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

import SignInInterface

@MainActor
final class SignInRouterSpy {
    private(set) var routes: [SignInRoute] = []

    func route(to route: SignInRoute) {
        routes.append(route)
    }
}
