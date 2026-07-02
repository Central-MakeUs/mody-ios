//
//  OnBoardingStepThreeView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI
import ComposableArchitecture

public struct OnBoardingStepThreeView: View {
    private let store: StoreOf<OnBoardingStepThreeFeature>

    public init(store: StoreOf<OnBoardingStepThreeFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Step Three Body")
            .font(.title2)
    }
}
