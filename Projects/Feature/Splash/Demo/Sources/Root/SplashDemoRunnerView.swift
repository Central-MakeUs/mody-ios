//
//  SplashDemoRunnerView.swift
//  SplashDemo
//
//  Created by 김동준 on 8/20/26.
//

import DesignSystem
import SplashInterface
import SwiftUI

@MainActor
struct SplashDemoRunnerView: View {
    private let builder: SplashBuildable
    private let router: SplashRouter
    private let onScenarioControlTap: () -> Void

    init(
        builder: SplashBuildable,
        router: SplashRouter,
        onScenarioControlTap: @escaping () -> Void
    ) {
        self.builder = builder
        self.router = router
        self.onScenarioControlTap = onScenarioControlTap
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            SplashDemoBuilder(
                builder: builder,
                router: router
            )

            scenarioControlButton
                .padding(24)
        }
    }
}

private extension SplashDemoRunnerView {
    var scenarioControlButton: some View {
        Button(action: onScenarioControlTap) {
            Image.icMultiple
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
