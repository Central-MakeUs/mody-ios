//
//  ChallengeScenarioControlView.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import DesignSystem
import SwiftUI

struct ChallengeScenarioControlView: View {
    @Binding private var selection: ChallengeDemoScenario
    private let lastRoute: String
    private let lastOutput: String
    private let onRun: () -> Void

    init(
        selection: Binding<ChallengeDemoScenario>,
        lastRoute: String,
        lastOutput: String,
        onRun: @escaping () -> Void
    ) {
        self._selection = selection
        self.lastRoute = lastRoute
        self.lastOutput = lastOutput
        self.onRun = onRun
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MText("Challenge Scenario", style: .b3, color: .gray10, alignment: .leading)

            Picker("시나리오", selection: $selection) {
                ForEach(ChallengeDemoScenario.allCases) { scenario in
                    Text(scenario.name).tag(scenario)
                }
            }
            .pickerStyle(.menu)

            MText(selection.instructions, style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)
            MText(selection.expectedNavigation, style: .c1, color: .gray10, lineLimit: nil, alignment: .leading)
            MText("마지막 이동: \(lastRoute)", style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)
            MText("마지막 출력: \(lastOutput)", style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)

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
