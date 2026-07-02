//
//  OnBoardingStepFourView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI
import ComposableArchitecture

public struct OnBoardingStepFourView: View {
    private let store: StoreOf<OnBoardingStepFourFeature>

    public init(store: StoreOf<OnBoardingStepFourFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Step Four Body")
            .font(.title2)
    }
}
