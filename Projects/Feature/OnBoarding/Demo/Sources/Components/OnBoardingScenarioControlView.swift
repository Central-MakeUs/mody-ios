//
//  OnBoardingScenarioControlView.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import DesignSystem
import OnBoardingInterface
import SwiftUI

struct OnBoardingScenarioControlView: View {
    @Binding private var selection: OnBoardingScenario
    private let route: OnBoardingRoute?
    private let onRun: () -> Void

    init(
        selection: Binding<OnBoardingScenario>,
        route: OnBoardingRoute?,
        onRun: @escaping () -> Void
    ) {
        self._selection = selection
        self.route = route
        self.onRun = onRun
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MText("OnBoarding Scenario", style: .b3, color: .gray10, alignment: .leading)

            Picker("시나리오", selection: $selection) {
                ForEach(OnBoardingScenario.allCases) { scenario in
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
        case .some(.routeToGroupParticipate): "마지막 이동: 그룹 참여"
        }
    }
}
