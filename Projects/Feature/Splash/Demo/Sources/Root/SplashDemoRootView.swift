//
//  SplashDemoRootView.swift
//  SplashDemo
//
//  Created by 김동준 on 8/20/26.
//

import ComposableArchitecture
import DesignSystem
import SplashInterface
import SwiftUI

struct SplashDemoRootView: View {
    @Bindable private var store: StoreOf<SplashDemoFeature>
    private let makeSplashBuilder: (SplashScenario) -> SplashBuildable
    private let router: SplashRouter

    init(
        store: StoreOf<SplashDemoFeature>,
        makeSplashBuilder: @escaping (SplashScenario) -> SplashBuildable,
        router: SplashRouter
    ) {
        self.store = store
        self.makeSplashBuilder = makeSplashBuilder
        self.router = router
    }

    var body: some View {
        splashDemoBody
            .sheet(isPresented: $store.isScenarioSheetPresented) {
                SplashScenarioControlView(
                    selection: $store.selectedScenario,
                    onRun: { store.send(.runScenarioTapped) }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(36)
                .background(Color.systemWhite)
            }
    }
}

private extension SplashDemoRootView {
    @ViewBuilder
    var splashDemoBody: some View {
        SplashDemoRunnerView(
            builder: makeSplashBuilder(store.runningScenario),
            router: router,
            onScenarioControlTap: { store.send(.scenarioControlTapped) }
        )
        .id(store.runID)
    }
}
