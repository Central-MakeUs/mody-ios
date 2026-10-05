//
//  FeedDemoScenarioControlView.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import DesignSystem
import SwiftUI

struct FeedDemoScenarioControlView: View {
    @Binding private var selection: FeedDemoScenario
    private let lastEvent: String
    private let onRun: () -> Void

    init(selection: Binding<FeedDemoScenario>, lastEvent: String, onRun: @escaping () -> Void) {
        self._selection = selection
        self.lastEvent = lastEvent
        self.onRun = onRun
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MText("Feed Scenario", style: .b3, color: .gray10, alignment: .leading)

            Picker("시나리오", selection: $selection) {
                ForEach(FeedDemoScenario.allCases) { scenario in
                    Text(scenario.title).tag(scenario)
                }
            }
            .pickerStyle(.menu)

            MText(selection.instructions, style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)
            MText(selection.expectedNavigation, style: .c1, color: .gray10, lineLimit: nil, alignment: .leading)
            MText("마지막 이동·결과: \(lastEvent)", style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)

            Spacer(minLength: 20)

            MButton("이 시나리오 실행", horizontalPadding: 0, verticalPadding: 12, maxWidth: .infinity, action: onRun)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(Color.systemWhite)
    }
}
