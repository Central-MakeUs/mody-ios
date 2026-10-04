//
//  SignInDemoRootView.swift
//  SignInDemo
//
//  Created by 김동준 on 10/1/26.
//

import ComposableArchitecture
import DesignSystem
import SignInInterface
import SwiftUI

struct SignInDemoRootView: View {
    @Bindable private var store: StoreOf<SignInDemoFeature>
    private let makeSignInBuilder: (SignInScenario) -> SignInBuildable
    private let router: SignInRouter

    init(
        store: StoreOf<SignInDemoFeature>,
        makeSignInBuilder: @escaping (SignInScenario) -> SignInBuildable,
        router: SignInRouter
    ) {
        self.store = store
        self.makeSignInBuilder = makeSignInBuilder
        self.router = router
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SignInDemoBuilder(
                builder: makeSignInBuilder(store.runningScenario),
                router: router
            )
            .ignoresSafeArea()
            .id(store.runID)

            scenarioControlButton
                .padding(24)
        }
        .sheet(isPresented: $store.isScenarioSheetPresented) {
            SignInScenarioControlView(
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

private extension SignInDemoRootView {
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
