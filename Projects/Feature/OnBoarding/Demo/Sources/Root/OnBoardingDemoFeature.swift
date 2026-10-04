//
//  OnBoardingDemoFeature.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import OnBoardingInterface

@Reducer
struct OnBoardingDemoFeature {
    @ObservableState
    struct State: Equatable {
        var runningScenario = OnBoardingScenario.profileSuccess
        var selectedScenario = OnBoardingScenario.profileSuccess
        var isScenarioSheetPresented = false
        var route: OnBoardingRoute?
        var runID = 0
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case scenarioControlTapped
        case runScenarioTapped
        case routeReceived(OnBoardingRoute)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .scenarioControlTapped:
                state.selectedScenario = state.runningScenario
                state.isScenarioSheetPresented = true
                return .none
            case .runScenarioTapped:
                state.runningScenario = state.selectedScenario
                state.isScenarioSheetPresented = false
                state.route = nil
                state.runID += 1
                return .none
            case let .routeReceived(route):
                state.route = route
                return .none
            }
        }
    }
}
