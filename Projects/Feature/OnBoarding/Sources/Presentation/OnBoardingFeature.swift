//
//  OnBoardingFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import Foundation
import OnBoardingInterface

@Reducer
public struct OnBoardingFeature {
    private let onBoardingUseCase: OnBoardingUseCase
    private let router: @MainActor (OnBoardingRoute) -> Void

    public init(
        onBoardingUseCase: OnBoardingUseCase,
        router: @escaping @MainActor (OnBoardingRoute) -> Void
    ) {
        self.onBoardingUseCase = onBoardingUseCase
        self.router = router
    }
    
    @ObservableState
    public struct State: Equatable {
        struct StepStoredRequest: Equatable {
            var nickname: String?
            var birthDate: String?
        }

        enum Step: Int, CaseIterable, Equatable {
            case one = 1
            case two = 2
            case three = 3
            case four = 4
        }

        var currentStep: Step = .one
        var request: StepStoredRequest = .init()
        var stepOne: OnBoardingStepOneFeature.State = .init()
        var stepTwo: OnBoardingStepTwoFeature.State = .init()
        var stepThree: OnBoardingStepThreeFeature.State = .init()
        var stepFour: OnBoardingStepFourFeature.State = .init()

        var buttonTitle: String {
            switch currentStep {
            case .one, .two, .three:
                return "다음으로"
            case .four:
                return "완료"
            }
        }

        var isNextButtonEnabled: Bool {
            switch currentStep {
            case .one:
                return stepOne.isNextButtonEnabled
            case .two:
                return stepTwo.isNextButtonEnabled
            case .three:
                return stepThree.isNextButtonEnabled
            case .four:
                return stepFour.isNextButtonEnabled
            }
        }

        public init() {}
    }
    
    public enum Action {
        case nextButtonTapped
        case stepOne(OnBoardingStepOneFeature.Action)
        case stepTwo(OnBoardingStepTwoFeature.Action)
        case stepThree(OnBoardingStepThreeFeature.Action)
        case stepFour(OnBoardingStepFourFeature.Action)
        case routeToGroupParticipate
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.stepOne, action: \.stepOne) {
            OnBoardingStepOneFeature()
        }

        Scope(state: \.stepTwo, action: \.stepTwo) {
            OnBoardingStepTwoFeature()
        }

        Scope(state: \.stepThree, action: \.stepThree) {
            OnBoardingStepThreeFeature()
        }

        Scope(state: \.stepFour, action: \.stepFour) {
            OnBoardingStepFourFeature()
        }

        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                guard state.isNextButtonEnabled else {
                    return .none
                }
                updateRequest(from: &state)
                return moveNext(from: &state)
            case .stepOne:
                return .none
            case .stepTwo:
                return .none
            case .stepThree:
                return .none
            case .stepFour:
                return .none
            case .routeToGroupParticipate:
                return .run { [router] _ in
                    await router(.routeToGroupParticipate)
                }
            }
        }
    }
}

private extension OnBoardingFeature {
    func updateRequest(from state: inout State) {
        switch state.currentStep {
        case .one:
            let nickname = state.stepOne.nickname
            state.request.nickname = nickname
        case .two:
            state.request.birthDate = birthDateString(from: state.stepTwo)
        case .three, .four:
            break
        }
    }

    func birthDateString(from state: OnBoardingStepTwoFeature.State) -> String {
        let components = state.calendar.dateComponents(
            [.year, .month, .day],
            from: state.birthDate
        )
        guard
            let year = components.year,
            let month = components.month,
            let day = components.day
        else {
            return ""
        }
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    func moveNext(from state: inout State) -> Effect<Action> {
        switch state.currentStep {
        case .one:
            state.currentStep = .two
            return .none
        case .two:
            state.currentStep = .three
            return .none
        case .three:
            state.currentStep = .four
            return .none
        case .four:
            return .send(.routeToGroupParticipate)
        }
    }
}
