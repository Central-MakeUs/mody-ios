//
//  SplashScenarioControlView.swift
//  SplashDemo
//
//  Created by 김동준 on 8/20/26.
//

import DesignSystem
import SplashInterface
import SwiftUI

struct SplashScenarioControlView: View {
    @Binding private var selection: SplashScenario
    private let route: SplashRoute?
    private let onRun: () -> Void

    init(
        selection: Binding<SplashScenario>,
        route: SplashRoute?,
        onRun: @escaping () -> Void
    ) {
        self._selection = selection
        self.route = route
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

            MText(
                selection.expectedNavigationDescription,
                style: .c1,
                color: .gray10,
                lineLimit: nil,
                alignment: .leading
            )

            MText(
                routeDescription,
                style: .c1,
                color: .gray7,
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

    private var routeDescription: String {
        switch route {
        case .none: "마지막 이동: 없음"
        case .some(.routeToMain): "마지막 이동: 메인"
        case .some(.routeToSignIn): "마지막 이동: 로그인"
        case .some(.routeToOnBoarding): "마지막 이동: 온보딩"
        case let .some(.routeToModyGroup(showSignUpDoneContents)):
            showSignUpDoneContents
                ? "마지막 이동: 그룹 · 가입 완료 안내"
                : "마지막 이동: 그룹"
        }
    }
}
