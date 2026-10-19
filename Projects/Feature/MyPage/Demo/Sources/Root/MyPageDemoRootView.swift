//
//  MyPageDemoRootView.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

struct MyPageDemoRootView: View {
    @Bindable private var store: StoreOf<MyPageDemoFeature>

    init(store: StoreOf<MyPageDemoFeature>) {
        self.store = store
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MyPageDemoBuilder(
                scenario: store.runningScenario,
                onRoute: { store.send(.routeReceived($0)) },
                onOutput: { store.send(.outputReceived($0)) }
            )
            .ignoresSafeArea()
            .id(store.runID)

            if store.isScenarioButtonVisible {
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
                .padding(24)
            }
        }
        .mLoading(isPresent: store.isWeightLoading)
        .sheet(isPresented: $store.isScenarioSheetPresented) {
            MyPageScenarioControlView(
                selection: $store.selectedScenario,
                lastRoute: store.lastRoute,
                lastOutput: store.lastOutput,
                onRun: { store.send(.runScenarioTapped) }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(36)
            .background(Color.systemWhite)
        }
    }
}
