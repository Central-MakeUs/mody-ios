//
//  SplashDemoApp.swift
//  SplashDemo
//
//  Created by 김동준 on 8/20/26.
//

import ComposableArchitecture
import SplashInterface
import SwiftUI

@main
struct SplashDemoApp: App {
    private let store: StoreOf<SplashDemoFeature>
    private let dependencyContainer: SplashDemoDependencyContainer
    private let router: SplashRouter

    init() {
        let dependencyContainer = SplashDemoDependencyContainer()

        self.store = Store(initialState: SplashDemoFeature.State()) {
            SplashDemoFeature()
        }
        self.dependencyContainer = dependencyContainer
        self.router = dependencyContainer.makeSplashRouter()
    }

    var body: some Scene {
        WindowGroup {
            SplashDemoRootView(
                store: store,
                makeSplashBuilder: dependencyContainer.makeSplashBuilder,
                router: router
            )
        }
    }
}
