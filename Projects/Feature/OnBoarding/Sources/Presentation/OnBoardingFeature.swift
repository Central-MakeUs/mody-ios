//
//  OnBoardingFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 6/25/26
//

import ComposableArchitecture
import OnBoardingInterface
import CommonDomain
import Foundation
import Util
import CoreCameraInterface
import CoreNotificationInterface
import Base

@Reducer
public struct OnBoardingFeature {
    private let onBoardingUseCase: OnBoardingUseCase
    private let cameraPermission: CameraPermissionInterface
    private let notificationPermission: NotificationPermissionInterface
    private let router: @MainActor (OnBoardingRoute) -> Void

    public init(
        onBoardingUseCase: OnBoardingUseCase,
        cameraPermission: CameraPermissionInterface,
        notificationPermission: NotificationPermissionInterface,
        router: @escaping @MainActor (OnBoardingRoute) -> Void
    ) {
        self.onBoardingUseCase = onBoardingUseCase
        self.cameraPermission = cameraPermission
        self.notificationPermission = notificationPermission
        self.router = router
    }
    
    @ObservableState
    public struct State: Equatable {
        public enum AlertCase: Equatable {
            case error(NetworkError)
        }

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
            case permission = 5
        }

        var isLoading: Bool = false
        var isPermissionRequesting = false
        var currentStep: Step = .one
        var request: StepStoredRequest = .init()
        var stepOne: OnBoardingStepOneFeature.State = .init()
        var stepTwo: OnBoardingStepTwoFeature.State = .init()
        var stepThree: OnBoardingStepThreeFeature.State = .init()
        var stepFour: OnBoardingStepFourFeature.State = .init()
        var alertCase: AlertCase?
        var alertState = AlertFeature.State()
        let isHealthPermissionVisible: Bool

        var buttonTitle: String {
            currentStep == .permission ? "확인" : "다음으로"
        }

        var showsStepIndicator: Bool {
            currentStep != .permission
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
            case .permission:
                return !isPermissionRequesting
            }
        }

        public init(isPhaseOne: Bool = PhaseManager.shared.isPhaseOne) {
            self.isHealthPermissionVisible = !isPhaseOne
        }
    }
    
    public enum Action {
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case nextButtonTapped
        case stepOne(OnBoardingStepOneFeature.Action)
        case stepTwo(OnBoardingStepTwoFeature.Action)
        case stepThree(OnBoardingStepThreeFeature.Action)
        case stepFour(OnBoardingStepFourFeature.Action)
        case setUpProfile
        case setupProfileSuccessfully
        case setupProfileFailure(NetworkError)
        case requestPermissions
        case permissionsRequestCompleted
        case routeToGroupParticipate
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.alertState, action: \.alertAction) {
            AlertFeature()
        }

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
            case .alertAction:
                return .none
            case let .showAlert(alertCase):
                state.isLoading = false
                state.alertCase = alertCase
                return .send(.alertAction(.present))
            case .nextButtonTapped:
                guard state.isNextButtonEnabled else { return .none }

                if state.currentStep == .permission {
                    return .send(.requestPermissions)
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
                    } catch {
                        await send(.setupProfileFailure(error as? NetworkError ?? .unknown))
                    }
                }
            case .setupProfileSuccessfully:
                state.isLoading = false
                state.currentStep = .permission
                return .none
            case let .setupProfileFailure(error):
                return .send(.showAlert(.error(error)))
            case .requestPermissions:
                guard !state.isPermissionRequesting else { return .none }
                state.isPermissionRequesting = true

                return .run { send in
                    _ = await notificationPermission.requestNotificationPermission()
                    _ = await cameraPermission.requestCameraPermission()
                    await send(.permissionsRequestCompleted)
                }
            case .permissionsRequestCompleted:
                state.isPermissionRequesting = false
                return .send(.routeToGroupParticipate)
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
            state.request.birthDate = birthDateString(from: state.stepTwo.birthDate)
        case .three:
            state.request.currentWeightKg = Double(state.stepThree.currentWeightKg)
            state.request.targetWeightKg = Double(state.stepThree.targetWeightKg)
        case .four:
            state.request.mealSchedules = state.stepFour.request.mealSchedules
            state.request.exerciseSchedules = state.stepFour.request.exerciseSchedules
        case .permission:
            break
        }
    }

    func birthDateString(from birthDate: Date) -> String {
        birthDate.toString(format: .yyyyMMdd)
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
        case .permission:
            return .none
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
