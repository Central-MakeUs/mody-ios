//
//  ModyGroupDemoApp.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import ModyGroupInterface
import SwiftUI

@main
struct ModyGroupDemoApp: App {
    private let store: StoreOf<ModyGroupDemoFeature>
    private let dependencyContainer = ModyGroupDemoDependencyContainer()
    private let router: ModyGroupRouter
    private let outputHandler: ModyGroupOutputHandler

    init() {
        let store = Store(initialState: ModyGroupDemoFeature.State()) {
            ModyGroupDemoFeature()
        }
        self.store = store
        self.router = ModyGroupDemoRouter { route in
            store.send(.routeReceived(route))
        }
        self.outputHandler = ModyGroupDemoOutputHandler { output in
            store.send(.outputReceived(output))
        }
    }

    var body: some Scene {
        WindowGroup {
            ModyGroupDemoRootView(
                store: store,
                makeBuilder: dependencyContainer.makeBuilder,
                router: router,
                outputHandler: outputHandler
            )
        }
    }
}
