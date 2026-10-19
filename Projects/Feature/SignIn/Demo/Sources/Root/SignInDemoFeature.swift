//
//  SignInDemoFeature.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import ComposableArchitecture
import SignInInterface

@Reducer
struct SignInDemoFeature {
    @ObservableState
    struct State: Equatable {
        var runningScenario = SignInScenario.mainAccessible
        var selectedScenario = SignInScenario.mainAccessible
        var isScenarioSheetPresented = false
        var route: SignInRoute?
        var runID = 0
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case scenarioControlTapped
        case runScenarioTapped
        case routeReceived(SignInRoute)
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
