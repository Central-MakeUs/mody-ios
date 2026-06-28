//
//  SplashView.swift
//  Splash
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import ComposableArchitecture

public struct SplashView: View {
    private let store: StoreOf<SplashFeature>
    
    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Hello, Splash~")
            .onAppear { store.send(.onAppear) }
    }
}
