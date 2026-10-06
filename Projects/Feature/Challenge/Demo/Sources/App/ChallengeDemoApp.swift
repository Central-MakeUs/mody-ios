//
//  ChallengeDemoApp.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct ChallengeDemoApp: App {
    private let store: StoreOf<ChallengeDemoFeature>
    private let dependencyContainer = ChallengeDemoDependencyContainer()
    private let router: ChallengeDemoRouter

    init() {
        let store = Store(initialState: ChallengeDemoFeature.State()) {
            ChallengeDemoFeature()
        }
        self.store = store
        self.router = ChallengeDemoRouter(
            onRoute: { store.send(.routeReceived($0)) },
            onOutput: { store.send(.outputReceived($0)) }
        )
    }

    var body: some Scene {
        WindowGroup {
            ChallengeDemoRootView(
                store: store,
                makeBuilder: dependencyContainer.makeBuilder,
                router: router
            )
        }
    }
}
