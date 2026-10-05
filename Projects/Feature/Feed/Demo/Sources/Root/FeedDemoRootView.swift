//
//  FeedDemoRootView.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import ComposableArchitecture
import DesignSystem
import FeedInterface
import SwiftUI

struct FeedDemoRootView: View {
    @Bindable private var store: StoreOf<FeedDemoFeature>
    private let makeBuilder: (FeedDemoScenario) -> FeedBuildable
    private let addDemoRecord: @MainActor () async -> Void
    private let router: FeedDemoRouter
    private let outputHandler: FeedDemoOutputHandler

    init(
        store: StoreOf<FeedDemoFeature>,
        makeBuilder: @escaping (FeedDemoScenario) -> FeedBuildable,
        addDemoRecord: @escaping @MainActor () async -> Void,
        router: FeedDemoRouter,
        outputHandler: FeedDemoOutputHandler
    ) {
        self.store = store
        self.makeBuilder = makeBuilder
        self.addDemoRecord = addDemoRecord
        self.router = router
        self.outputHandler = outputHandler
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            FeedDemoBuilder(
                makeBuilder: makeBuilder,
                scenario: store.runningScenario,
                router: router,
                outputHandler: outputHandler
            )
            .id(store.runID)
            .ignoresSafeArea(.container)

            HStack(spacing: 12) {
                scenarioControlButton
                if store.runningScenario == .addRecord {
                    addRecordButton
                }
            }
                .padding(24)
                .ignoresSafeArea(.container)
        }
        .sheet(isPresented: $store.isScenarioSheetPresented) {
            FeedDemoScenarioControlView(
                selection: $store.selectedScenario,
                lastEvent: store.lastEvent,
                onRun: { store.send(.runScenarioTapped) }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(36)
        }
    }
}

private extension FeedDemoRootView {
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

    var addRecordButton: some View {
        Button {
            Task {
                await addDemoRecord()
                router.sendFeedInput(.refreshGroups)
            }
        } label: {
            MText("+", style: .h2, color: .systemWhite)
                .frame(width: 56, height: 56)
                .background(Color.gray10)
                .clipShape(Circle())
        }
    }
}
