//
//  MyPageScenarioControlView.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import DesignSystem
import MyPageInterface
import SwiftUI

struct MyPageScenarioControlView: View {
    @Binding private var selection: MyPageScenario
    private let lastRoute: String?
    private let lastOutput: MyPageOutput?
    private let onRun: () -> Void

    init(
        selection: Binding<MyPageScenario>,
        lastRoute: String?,
        lastOutput: MyPageOutput?,
        onRun: @escaping () -> Void
    ) {
        self._selection = selection
        self.lastRoute = lastRoute
        self.lastOutput = lastOutput
        self.onRun = onRun
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MText("MyPage Scenario", style: .b3, color: .gray10, alignment: .leading)

            Picker("시나리오", selection: $selection) {
                ForEach(MyPageScenario.allCases) { scenario in
                    Text(scenario.displayName).tag(scenario)
                }
            }
            .pickerStyle(.menu)

            MText(selection.summary, style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)
            MText(selection.expectedNavigation, style: .c1, color: .gray10, lineLimit: nil, alignment: .leading)
            MText("마지막 이동: \(lastRoute ?? "없음")", style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)
            MText(outputDescription, style: .c1, color: .gray7, lineLimit: nil, alignment: .leading)

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

    private var outputDescription: String {
        switch lastOutput {
        case .none: "마지막 출력: 없음"
        case .some(.weightRecordStarted): "마지막 출력: 체중 기록 시작"
        case .some(.weightRecordSucceeded): "마지막 출력: 체중 기록 성공"
        case let .some(.weightRecordFailed(error)): "마지막 출력: 체중 기록 실패 · \(error)"
        case .some(.profileUpdated): "마지막 출력: 프로필 갱신"
        case .some(.groupUpdated): "마지막 출력: 그룹 갱신"
        }
    }
}
