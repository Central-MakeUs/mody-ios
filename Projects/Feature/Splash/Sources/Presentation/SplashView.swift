//
//  SplashView.swift
//  Splash
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct SplashView: View {
    private let store: StoreOf<SplashFeature>
    
    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }
    
    public var body: some View {
        splashBody
            .onAppear { store.send(.onAppear) }
            .mLoading(isPresent: store.isLoading)
    }
    
    private var splashBody: some View {
        VStack(spacing: 0) {
            Text("Hello, Splash~")
        }
    }
}
