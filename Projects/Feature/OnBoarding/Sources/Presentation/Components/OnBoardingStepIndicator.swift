//
//  OnBoardingStepIndicator.swift
//  OnBoarding
//
//  Created by 김동준 on 7/4/26
//

import SwiftUI
import DesignSystem

public struct OnBoardingStepIndicator: View {
    private let currentStep: Int
    private let totalStepCount: Int = 4

    public init(currentStep: Int) {
        self.currentStep = currentStep
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(1...max(totalStepCount, 1), id: \.self) { step in
                Capsule()
                    .fill(step == currentStep ? Color.main : Color.gray2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
    }
}
