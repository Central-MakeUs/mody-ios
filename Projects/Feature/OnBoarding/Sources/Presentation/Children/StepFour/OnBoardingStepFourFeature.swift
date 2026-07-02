//
//  OnBoardingStepFourFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import ComposableArchitecture

@Reducer
public struct OnBoardingStepFourFeature {
    @ObservableState
    public struct State: Equatable {
        var isNextButtonEnabled: Bool = true

        public init() {}
    }

    public enum Action {
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
