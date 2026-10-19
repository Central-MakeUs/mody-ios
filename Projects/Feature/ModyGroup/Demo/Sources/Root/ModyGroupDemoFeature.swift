//
//  ModyGroupDemoFeature.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import ModyGroupInterface

@Reducer
struct ModyGroupDemoFeature {
    @ObservableState
    struct State: Equatable {
        var runningScenario = ModyGroupScenario.joinSuccess
        var selectedScenario = ModyGroupScenario.joinSuccess
        var isScenarioSheetPresented = false
        var route: ModyGroupRoute?
        var output: ModyGroupOutput?
        var runID = 0
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case scenarioControlTapped
        case runScenarioTapped
        case routeReceived(ModyGroupRoute)
        case outputReceived(ModyGroupOutput)
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
                state.output = nil
                state.runID += 1
                return .none
            case let .routeReceived(route):
                state.route = route
                return .none
            case let .outputReceived(output):
                state.output = output
                return .none
            }
        }
    }
}
