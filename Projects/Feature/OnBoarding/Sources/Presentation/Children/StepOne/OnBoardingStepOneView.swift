//
//  OnBoardingStepOneView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI
import ComposableArchitecture

public struct OnBoardingStepOneView: View {
    private let store: StoreOf<OnBoardingStepOneFeature>

    public init(store: StoreOf<OnBoardingStepOneFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Step One Body")
            .font(.title2)
    }
}
