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
    private let store = Store(initialState: ChallengeDemoFeature.State()) {
        ChallengeDemoFeature()
    }

    var body: some Scene {
        WindowGroup {
            ChallengeDemoRootView(store: store)
        }
    }
}
