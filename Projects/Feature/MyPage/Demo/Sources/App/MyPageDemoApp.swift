//
//  MyPageDemoApp.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import SwiftUI

@main
struct MyPageDemoApp: App {
    private let store = Store(initialState: MyPageDemoFeature.State()) {
        MyPageDemoFeature()
    }

    var body: some Scene {
        WindowGroup {
            MyPageDemoRootView(store: store)
        }
    }
}
