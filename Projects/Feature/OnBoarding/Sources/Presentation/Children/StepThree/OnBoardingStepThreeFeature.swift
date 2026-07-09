//
//  OnBoardingStepThreeFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import ComposableArchitecture

@Reducer
public struct OnBoardingStepThreeFeature {
    @ObservableState
    public struct State: Equatable {
        enum WeightGoalStatus: Equatable {
            case lose(Int)
            case maintain
            case gain(Int)
        }

        let selectableWeights = Array(20...150)
        var currentWeightKg: Int = 57
        var targetWeightKg: Int = 60
        var isNextButtonEnabled: Bool = true

        var goalStatus: WeightGoalStatus {
            let difference = targetWeightKg - currentWeightKg
            if difference < 0 {
                return .lose(abs(difference))
            } else if difference > 0 {
                return .gain(difference)
            } else {
                return .maintain
            }
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                break
            }

            return .none
        }
    }
}
