//
//  ModyGroupScenarioControlView.swift
//  ModyGroupDemo
//
//  Created by 김동준 on 10/4/26.
//

import DesignSystem
import ModyGroupInterface
import SwiftUI

struct ModyGroupScenarioControlView: View {
    @Binding private var selection: ModyGroupScenario
    private let route: ModyGroupRoute?
    private let output: ModyGroupOutput?
    private let onRun: () -> Void

    init(
        selection: Binding<ModyGroupScenario>,
        route: ModyGroupRoute?,
        output: ModyGroupOutput?,
        onRun: @escaping () -> Void
    ) {
        self._selection = selection
        self.route = route
        self.output = output
        self.onRun = onRun
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MText("ModyGroup Scenario", style: .b3, color: .gray10, alignment: .leading)

            Picker("시나리오", selection: $selection) {
                ForEach(ModyGroupScenario.allCases) { scenario in
                    Text(scenario.displayName).tag(scenario)
                }
            }
            .pickerStyle(.menu)

            MText(selection.summary, style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)
            MText(
                selection.expectedNavigationDescription,
                style: .c1,
                color: .gray10,
                lineLimit: nil,
                alignment: .leading
            )
            MText(routeDescription, style: .c1, color: .gray7, alignment: .leading)
            MText(outputDescription, style: .c1, color: .gray7, alignment: .leading)

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

    private var routeDescription: String {
        switch route {
        case .none: "마지막 이동: 없음"
        case .some(.back): "마지막 이동: 뒤로"
        case .some(.finish): "마지막 이동: 완료"
        }
    }

    private var outputDescription: String {
        switch output {
        case .none: "마지막 출력: 없음"
        case .some(.groupUpdated): "마지막 출력: 그룹 갱신"
        }
    }
}
