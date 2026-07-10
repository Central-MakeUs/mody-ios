//
//  OnBoardingFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import OnBoardingInterface
import CommonDomain

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
            var currentWeightKg: Double?
            var targetWeightKg: Double?
            var mealSchedules: [MealScheduleRequest] = []
            var exerciseSchedules: [ExerciseScheduleRequest] = []
        }

        enum Step: Int, CaseIterable, Equatable {
            case one = 1
            case two = 2
            case three = 3
            case four = 4
        }

        var isLoading: Bool = false
        var currentStep: Step = .one
        var request: StepStoredRequest = .init()
        var stepOne: OnBoardingStepOneFeature.State = .init()
        var stepTwo: OnBoardingStepTwoFeature.State = .init()
        var stepThree: OnBoardingStepThreeFeature.State = .init()
        var stepFour: OnBoardingStepFourFeature.State = .init()

        let buttonTitle: String = "다음으로"

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
        case setUpProfile
        case setupProfileSuccessfully
        case setupProfileFailure(NetworkError)
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
            case .setUpProfile:
                guard let request = makeRequest(from: state.request) else { return .none }
                
                state.isLoading = true
                
                return .run { send in
                    do {
                        try await onBoardingUseCase.setupOnBoardingProfileInfo(request: request)
                        await send(.setupProfileSuccessfully)
                    } catch let error as NetworkError {
                        await send(.setupProfileFailure(error))
                    } catch {
                        await send(.setupProfileFailure(.unknown))
                    }
                }
            case .setupProfileSuccessfully:
                state.isLoading = false
                return .send(.routeToGroupParticipate)
            case .setupProfileFailure:
                state.isLoading = false
                // TODO: Alert
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
        case .three:
            state.request.currentWeightKg = Double(state.stepThree.currentWeightKg)
            state.request.targetWeightKg = Double(state.stepThree.targetWeightKg)
        case .four:
            state.request.mealSchedules = state.stepFour.request.mealSchedules
            state.request.exerciseSchedules = state.stepFour.request.exerciseSchedules
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
            return .send(.setUpProfile)
        }
    }

    func makeRequest(from request: State.StepStoredRequest) -> OnBoardingProfileRequest? {
        guard
            let nickname = request.nickname,
            let birthDate = request.birthDate,
            let currentWeightKg = request.currentWeightKg,
            let targetWeightKg = request.targetWeightKg,
            !request.mealSchedules.isEmpty,
            !request.exerciseSchedules.isEmpty
        else {
            return nil
        }

        return OnBoardingProfileRequest(
            nickname: nickname,
            birthDate: birthDate,
            currentWeightKg: currentWeightKg,
            targetWeightKg: targetWeightKg,
            mealSchedules: request.mealSchedules,
            exerciseSchedules: request.exerciseSchedules
        )
    }
}
