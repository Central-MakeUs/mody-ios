//
//  SplashDemoFeature.swift
//  SplashDemo
//
//  Created by 김동준 on 8/21/26.
//

import ComposableArchitecture

@Reducer
struct SplashDemoFeature {
    @ObservableState
    struct State: Equatable {
        var runningScenario = SplashScenario.mainAccessible
        var selectedScenario = SplashScenario.mainAccessible
        var isScenarioSheetPresented = false
        var runID = 0
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case runScenarioTapped
        case scenarioControlTapped
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .runScenarioTapped:
                state.runningScenario = state.selectedScenario
                state.isScenarioSheetPresented = false
                state.runID += 1
                return .none
            case .scenarioControlTapped:
                state.selectedScenario = state.runningScenario
                state.isScenarioSheetPresented = true
                return .none
            }
        }
    }
}
