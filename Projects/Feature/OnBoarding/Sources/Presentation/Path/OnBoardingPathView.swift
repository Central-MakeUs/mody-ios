//
//  OnBoardingPathView.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import ComposableArchitecture

public struct OnBoardingPathView: View {
    private let store: StoreOf<OnBoardingPath>
    
    public init(store: StoreOf<OnBoardingPath>) {
        self.store = store
    }
    
    public var body: some View {
        switch store.case {
        case .temp(let store): TempView(store: store)
        }
    }
}
