//
//  SplashScenarioControlView.swift
//  SplashDemo
//
//  Created by 김동준 on 8/20/26.
//

import DesignSystem
import SplashTesting
import SwiftUI

struct SplashScenarioControlView: View {
    @Binding private var selection: SplashScenario
    private let onRun: () -> Void

    init(
        selection: Binding<SplashScenario>,
        onRun: @escaping () -> Void
    ) {
        self._selection = selection
        self.onRun = onRun
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MText(
                "Splash Scenario",
                style: .b3,
                color: .gray10,
                alignment: .leading
            )

            Picker("시나리오", selection: $selection) {
                ForEach(SplashScenario.allCases) { scenario in
                    Text(scenario.displayName)
                        .tag(scenario)
                }
            }
            .pickerStyle(.menu)

            MText(
                selection.summary,
                style: .c1,
                color: .gray7,
                lineLimit: nil,
                alignment: .leading
            )

            Spacer(minLength: 20)

            MButton(
                "이 시나리오 실행",
                horizontalPadding: 0,
                verticalPadding: 12,
                maxWidth: .infinity,
                action: onRun
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(Color.systemWhite)
    }
}
