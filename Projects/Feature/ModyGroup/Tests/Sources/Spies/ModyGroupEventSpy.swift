//
//  ModyGroupEventSpy.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import ModyGroupInterface

@MainActor
final class ModyGroupEventSpy {
    private(set) var routes: [ModyGroupRoute] = []
    private(set) var outputs: [ModyGroupOutput] = []
    private(set) var events: [String] = []

    func recordRoute(_ route: ModyGroupRoute) {
        routes.append(route)
        events.append("route")
    }

    func recordOutput(_ output: ModyGroupOutput) {
        outputs.append(output)
        events.append("output")
    }
}
