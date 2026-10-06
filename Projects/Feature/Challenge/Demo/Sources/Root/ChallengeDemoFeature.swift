//
//  ChallengeDemoFeature.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import ComposableArchitecture

@Reducer
struct ChallengeDemoFeature {
    @Dependency(\.continuousClock) private var clock

    private enum CancelID { case automaticSteps }

    @ObservableState
    struct State: Equatable {
        var runningScenario = ChallengeDemoScenario.overview
        var selectedScenario = ChallengeDemoScenario.overview
        var isScenarioSheetPresented = false
        var lastRoute = "없음"
        var lastOutput = "없음"
        var runID = 0
        var simulationTick = 0

        var isScenarioButtonVisible: Bool {
            lastRoute == "없음" || lastRoute.hasSuffix("→ 챌린지 홈")
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case scenarioControlTapped
        case runScenarioTapped
        case competitionButtonTapped
        case automaticStepTick
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
                state.lastRoute = "없음"
                state.lastOutput = "없음"
                state.runID += 1
                state.simulationTick = 0
                guard state.runningScenario == .stepLive else {
                    return .cancel(id: CancelID.automaticSteps)
                }
                return .run { [clock] send in
                    for await _ in clock.timer(interval: .seconds(3)) {
                        await send(.automaticStepTick)
                    }
                }
                .cancellable(id: CancelID.automaticSteps, cancelInFlight: true)
            case .competitionButtonTapped:
                guard state.runningScenario == .stepCompetition else { return .none }
                state.simulationTick += 1
                return .none
            case .automaticStepTick:
                guard state.runningScenario == .stepLive else { return .none }
                state.simulationTick += 1
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
