//
//  SignInDemoApp.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import ComposableArchitecture
import SignInInterface
import SwiftUI

@main
struct SignInDemoApp: App {
    private let store: StoreOf<SignInDemoFeature>
    private let dependencyContainer = SignInDemoDependencyContainer()
    private let router: SignInRouter

    init() {
        let store = Store(initialState: SignInDemoFeature.State()) {
            SignInDemoFeature()
        }
        self.store = store
        self.router = SignInDemoRouter { route in
            store.send(.routeReceived(route))
        }
    }

    var body: some Scene {
        WindowGroup {
            SignInDemoRootView(
                store: store,
                makeSignInBuilder: dependencyContainer.makeSignInBuilder,
                router: router
            )
        }
    }
}
