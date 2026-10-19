//
//  OnBoardingDemoRootView.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import DesignSystem
import OnBoardingInterface
import SwiftUI

struct OnBoardingDemoRootView: View {
    @Bindable private var store: StoreOf<OnBoardingDemoFeature>
    private let makeOnBoardingBuilder: (OnBoardingScenario) -> OnBoardingBuildable
    private let router: OnBoardingRouter

    init(
        store: StoreOf<OnBoardingDemoFeature>,
        makeOnBoardingBuilder: @escaping (OnBoardingScenario) -> OnBoardingBuildable,
        router: OnBoardingRouter
    ) {
        self.store = store
        self.makeOnBoardingBuilder = makeOnBoardingBuilder
        self.router = router
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            OnBoardingDemoBuilder(
                builder: makeOnBoardingBuilder(store.runningScenario),
                router: router
            )
            .ignoresSafeArea()
            .id(store.runID)

            scenarioControlButton
                .padding(24)
        }
        .sheet(isPresented: $store.isScenarioSheetPresented) {
            OnBoardingScenarioControlView(
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

private extension OnBoardingDemoRootView {
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
