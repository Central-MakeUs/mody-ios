//
//  OnBoardingDemoApp.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import OnBoardingInterface
import SwiftUI

@main
struct OnBoardingDemoApp: App {
    private let store: StoreOf<OnBoardingDemoFeature>
    private let dependencyContainer = OnBoardingDemoDependencyContainer()
    private let router: OnBoardingRouter

    init() {
        let store = Store(initialState: OnBoardingDemoFeature.State()) {
            OnBoardingDemoFeature()
        }
        self.store = store
        self.router = OnBoardingDemoRouter { route in
            store.send(.routeReceived(route))
        }
    }

    var body: some Scene {
        WindowGroup {
            OnBoardingDemoRootView(
                store: store,
                makeOnBoardingBuilder: dependencyContainer.makeOnBoardingBuilder,
                router: router
            )
        }
    }
}
