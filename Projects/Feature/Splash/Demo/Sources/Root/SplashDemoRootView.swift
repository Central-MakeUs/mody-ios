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
        ZStack(alignment: .bottomTrailing) {
            SplashDemoBuilder(
                builder: makeSplashBuilder(store.runningScenario),
                router: router
            )
            .ignoresSafeArea()
            .id(store.runID)

            scenarioControlButton
                .padding(24)
        }
        .sheet(isPresented: $store.isScenarioSheetPresented) {
            SplashScenarioControlView(
                selection: $store.selectedScenario,
                route: store.route,
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
