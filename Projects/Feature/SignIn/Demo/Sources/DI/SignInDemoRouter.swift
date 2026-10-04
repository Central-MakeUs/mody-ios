//
//  SignInDemoRouter.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import SignInInterface

@MainActor
final class SignInDemoRouter: SignInRouter {
    private let onRoute: (SignInRoute) -> Void

    init(onRoute: @escaping (SignInRoute) -> Void) {
        self.onRoute = onRoute
    }

    func route(from route: SignInRoute) {
        onRoute(route)
    }
}
