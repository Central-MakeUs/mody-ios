//
//  OnBoardingView.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import SwiftUI
import ComposableArchitecture

public struct OnBoardingView: View {
    private let store: StoreOf<OnBoardingFeature>

    public init(store: StoreOf<OnBoardingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            stepIndicator

            stepBody
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                store.send(.nextButtonTapped)
            } label: {
                Text(store.buttonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(!store.isNextButtonEnabled)
            .opacity(store.isNextButtonEnabled ? 1 : 0.4)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .padding(.top, 24)
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
