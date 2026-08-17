//
//  HealthDataSettingsView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct HealthDataSettingsView: View {
    @Environment(\.openURL) private var openURL

    private let store: StoreOf<HealthDataSettingsFeature>
    @State private var selectedStep = 1

    public init(store: StoreOf<HealthDataSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        healthDataSettingsBody
            .background(Color.systemWhite)
    }
}

private extension HealthDataSettingsView {
    var healthDataSettingsBody: some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "건강 데이터 연동 설정",
                onBackTap: { store.send(.backButtonTapped) }
            )
            .padding(.bottom, 48)

            stepTabView
                .frame(maxHeight: 470)

            HealthDataSettingsPageIndicator(selectedStep: selectedStep)
                .padding(.top, 30)
                .animation(.easeInOut, value: selectedStep)

            Spacer()

            MButton(
                "건강 데이터 설정하러 가기",
                verticalPadding: 13,
                maxWidth: .infinity,
                action: openHealthApp
            )
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    var stepTabView: some View {
        TabView(selection: $selectedStep) {
            ForEach(1...4, id: \.self) { step in
                ScrollView {
                    HealthDataSettingsStepView(step: step)
                        .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .tag(step)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    func openHealthApp() {
        guard let healthAppURL = URL(string: "x-apple-health://") else { return }
        openURL(healthAppURL)
    }
}
