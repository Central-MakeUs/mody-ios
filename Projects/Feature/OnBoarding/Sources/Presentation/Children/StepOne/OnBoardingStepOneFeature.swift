//
//  OnBoardingStepOneFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import ComposableArchitecture

@Reducer
public struct OnBoardingStepOneFeature {
    @ObservableState
    public struct State: Equatable {
        var nickname: String = ""
        let maxNicknameCount = 14

        var isNextButtonEnabled: Bool {
            !nickname.isEmpty && !isNicknameTooLong
        }

        var isNicknameTooLong: Bool {
            nickname.count > maxNicknameCount
        }
        
        var isNicknameValid: Bool? {
            guard !nickname.isEmpty else { return nil }
            return !isNicknameTooLong
        }
        
        var hasClearButton: Bool {
            !nickname.isEmpty
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
