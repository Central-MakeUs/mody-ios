//
//  FeedDemoApp.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import SwiftUI

@main
struct FeedDemoApp: App {
    @StateObject private var coordinator = FeedDemoCoordinator()

    var body: some Scene {
        WindowGroup {
            FeedDemoRootView(coordinator: coordinator)
                .ignoresSafeArea()
        }
    }
}
