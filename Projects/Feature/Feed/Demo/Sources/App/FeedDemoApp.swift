//
//  FeedDemoApp.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct FeedDemoApp: App {
    private let store: StoreOf<FeedDemoFeature>
    private let dependencyContainer = FeedDemoDependencyContainer()
    private let router: FeedDemoRouter
    private let outputHandler: FeedDemoOutputHandler

    init() {
        let store = Store(initialState: FeedDemoFeature.State()) {
            FeedDemoFeature()
        }
        self.store = store
        self.router = FeedDemoRouter { route in
            store.send(.routeReceived(route))
        }
        self.outputHandler = FeedDemoOutputHandler { output in
            store.send(.outputReceived(output))
        }
    }

    var body: some Scene {
        WindowGroup {
            FeedDemoRootView(
                store: store,
                makeBuilder: dependencyContainer.makeBuilder,
                addDemoRecord: dependencyContainer.addDemoRecord,
                router: router,
                outputHandler: outputHandler
            )
        }
    }
}
