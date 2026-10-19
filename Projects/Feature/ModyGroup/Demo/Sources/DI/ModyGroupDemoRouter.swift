//
//  ModyGroupDemoRouter.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import ModyGroupInterface

@MainActor
final class ModyGroupDemoRouter: ModyGroupRouter {
    private let onRoute: (ModyGroupRoute) -> Void

    init(onRoute: @escaping (ModyGroupRoute) -> Void) {
        self.onRoute = onRoute
    }

    func route(from route: ModyGroupRoute) {
        onRoute(route)
    }
}

@MainActor
final class ModyGroupDemoOutputHandler: ModyGroupOutputHandler {
    private let onOutput: (ModyGroupOutput) -> Void

    init(onOutput: @escaping (ModyGroupOutput) -> Void) {
        self.onOutput = onOutput
    }

    func handle(output: ModyGroupOutput) {
        onOutput(output)
    }
}
