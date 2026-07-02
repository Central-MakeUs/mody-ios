//
//  OnBoardingStepTwoView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI
import ComposableArchitecture

public struct OnBoardingStepTwoView: View {
    private let store: StoreOf<OnBoardingStepTwoFeature>

    public init(store: StoreOf<OnBoardingStepTwoFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Step Two Body")
            .font(.title2)
    }
}
