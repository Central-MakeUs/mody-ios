//
//  ChallengeDemoRootView.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import ComposableArchitecture
import CommonDomain
import DesignSystem
import SwiftUI

struct ChallengeDemoRootView: View {
    @Bindable private var store: StoreOf<ChallengeDemoFeature>

    init(store: StoreOf<ChallengeDemoFeature>) {
        self.store = store
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ChallengeDemoBuilder(
                scenario: store.runningScenario,
                simulationTick: store.simulationTick,
                onRoute: { store.send(.routeReceived($0)) },
                onOutput: { store.send(.outputReceived($0)) }
            )
            .ignoresSafeArea(.container)
            .id(store.runID)

            if store.isScenarioButtonVisible {
                HStack(spacing: 12) {
                    if store.runningScenario == .stepCompetition {
                        MButton("순위 바꾸기", style: .black) {
                            store.send(.competitionButtonTapped)
                        }
                    }

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
                .padding(24)
            }
        }
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        updateDeviceSize(using: geometry)
                    }
                    .onChange(of: geometry.size) { _, _ in
                        updateDeviceSize(using: geometry)
                    }
                    .onChange(of: geometry.safeAreaInsets.bottom) { _, _ in
                        updateDeviceSize(using: geometry)
                    }
            }
        }
        .sheet(isPresented: $store.isScenarioSheetPresented) {
            ChallengeScenarioControlView(
                selection: $store.selectedScenario,
                lastRoute: store.lastRoute,
                lastOutput: store.lastOutput,
                onRun: { store.send(.runScenarioTapped) }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(36)
            .background(Color.systemWhite)
        }
    }

    private func updateDeviceSize(using geometry: GeometryProxy) {
        DeviceSizeManager.shared.update(
            maxWidth: geometry.size.width,
            bottomSafeAreaInset: geometry.safeAreaInsets.bottom
        )
    }
}
