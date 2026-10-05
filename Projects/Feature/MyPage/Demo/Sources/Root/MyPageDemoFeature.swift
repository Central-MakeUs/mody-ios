//
//  MyPageDemoFeature.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import MyPageInterface

@Reducer
struct MyPageDemoFeature {
    @ObservableState
    struct State: Equatable {
        var runningScenario = MyPageScenario.overview
        var selectedScenario = MyPageScenario.overview
        var isScenarioSheetPresented = false
        var lastRoute: String?
        var lastOutput: MyPageOutput?
        var runID = 0

        var isWeightLoading: Bool { lastOutput == .weightRecordStarted }

        var isScenarioButtonVisible: Bool {
            guard let lastRoute else { return true }
            return lastRoute.contains("마이페이지")
                || lastRoute == "로그인"
                || lastRoute == "그룹 참여"
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case scenarioControlTapped
        case runScenarioTapped
        case routeReceived(String)
        case outputReceived(MyPageOutput)
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
                state.lastRoute = nil
                state.lastOutput = nil
                state.runID += 1
                return .none
            case let .routeReceived(route):
                state.lastRoute = route
                return .none
            case let .outputReceived(output):
                state.lastOutput = output
                return .none
            }
        }
    }
}
