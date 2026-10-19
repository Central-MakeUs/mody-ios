//
//  ModyGroupDemoRootView.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import DesignSystem
import ModyGroupInterface
import SwiftUI

struct ModyGroupDemoRootView: View {
    @Bindable private var store: StoreOf<ModyGroupDemoFeature>
    private let makeBuilder: (ModyGroupScenario) -> ModyGroupBuildable
    private let router: ModyGroupRouter
    private let outputHandler: ModyGroupOutputHandler

    init(
        store: StoreOf<ModyGroupDemoFeature>,
        makeBuilder: @escaping (ModyGroupScenario) -> ModyGroupBuildable,
        router: ModyGroupRouter,
        outputHandler: ModyGroupOutputHandler
    ) {
        self.store = store
        self.makeBuilder = makeBuilder
        self.router = router
        self.outputHandler = outputHandler
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ModyGroupDemoBuilder(
                builder: makeBuilder(store.runningScenario),
                scenario: store.runningScenario,
                router: router,
                outputHandler: outputHandler
            )
            .ignoresSafeArea()
            .id(store.runID)

            scenarioControlButton
                .padding(24)
        }
        .sheet(isPresented: $store.isScenarioSheetPresented) {
            ModyGroupScenarioControlView(
                selection: $store.selectedScenario,
                route: store.route,
                output: store.output,
                onRun: { store.send(.runScenarioTapped) }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(36)
            .background(Color.systemWhite)
        }
    }
}

private extension ModyGroupDemoRootView {
    var scenarioControlButton: some View {
        Button {
            store.send(.scenarioControlTapped)
        } label: {
            Image.icFireFill
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.gray10)
                .frame(width: 56, height: 56)
                .background(Color.main)
                .clipShape(Circle())
        }
    }
}
