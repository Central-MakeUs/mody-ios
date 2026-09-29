//
//  SplashDemoApp.swift
//  SplashDemo
//
//  Created by 김동준 on 8/20/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct SplashDemoApp: App {
    private let store = Store(initialState: SplashDemoFeature.State()) {
        SplashDemoFeature()
    }

    var body: some Scene {
        WindowGroup {
            SplashDemoRootView(store: store)
        }
    }
}
