//
//  OnBoardingView.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct OnBoardingView: View {
    private let store: StoreOf<OnBoardingFeature>

    public init(store: StoreOf<OnBoardingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        onBoardingBody
            .mLoading(isPresent: store.isLoading)
    }
    
    private var onBoardingBody: some View {
        VStack(spacing: 0) {
            stepIndicator

            stepBody
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            MButton(
                store.buttonTitle,
                style: store.isNextButtonEnabled ? .primary : .gray,
                isDisabled: !store.isNextButtonEnabled,
                horizontalPadding: 0,
                verticalPadding: 13,
                maxWidth: .infinity
            ) {
                store.send(.nextButtonTapped)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

private extension OnBoardingView {
    var stepIndicator: some View {
        OnBoardingStepIndicator(currentStep: store.currentStep.rawValue)
        .padding(.top, 20)
        .padding(.bottom, 48)
    }

    @ViewBuilder
    var stepBody: some View {
        switch store.currentStep {
        case .one:
            OnBoardingStepOneView(store: store.scope(state: \.stepOne, action: \.stepOne))
        case .two:
            OnBoardingStepTwoView(store: store.scope(state: \.stepTwo, action: \.stepTwo))
        case .three:
            OnBoardingStepThreeView(store: store.scope(state: \.stepThree, action: \.stepThree))
        case .four:
            OnBoardingStepFourView(store: store.scope(state: \.stepFour, action: \.stepFour))
        }
    }
}
