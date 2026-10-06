//
//  FeedDemoFeature.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import ComposableArchitecture

@Reducer
struct FeedDemoFeature {
    @ObservableState
    struct State: Equatable {
        var runningScenario = FeedDemoScenario.records
        var selectedScenario = FeedDemoScenario.records
        var isScenarioSheetPresented = false
        var lastEvent = "없음"
        var runID = 0
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case scenarioControlTapped
        case runScenarioTapped
        case routeReceived(String)
        case outputReceived(String)
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
                state.lastEvent = "없음"
                state.runID += 1
                return .none
            case let .routeReceived(event), let .outputReceived(event):
                state.lastEvent = event
                return .none
            }
        }
    }
}
