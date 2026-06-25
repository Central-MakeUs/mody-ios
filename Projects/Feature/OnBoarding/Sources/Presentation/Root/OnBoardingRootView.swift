//
//  OnBoardingRootView.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import SwiftUI

public struct OnBoardingRootView: View {
    @Bindable private var store: StoreOf<OnBoardingRootFeature>
    
    public init(store: StoreOf<OnBoardingRootFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            OnBoardingView(store: store.scope(state: \.onBoardingState, action: \.onBoardingAction))
        } destination: { store in
            OnBoardingPathView(store: store)
        }
    }
}
