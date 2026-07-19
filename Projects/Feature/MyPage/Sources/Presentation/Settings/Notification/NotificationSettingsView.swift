//
//  NotificationSettingsView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI
import UIKit

public struct NotificationSettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    private let store: StoreOf<NotificationSettingsFeature>

    public init(store: StoreOf<NotificationSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        notificationSettingBody
            .background(Color.systemWhite)
            .onAppear { store.send(.onAppear) }
            .onChange(of: scenePhase) { _, newValue in
                guard newValue == .active else { return }
                store.send(.checkNotificationPermission)
            }
    }

    private var notificationSettingBody: some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "알림 설정",
                onBackTap: { store.send(.backButtonTapped) }
            )
            ScrollView {
                VStack(spacing: 0) {
                    notificationPermissionRow

                    if !store.isNotificationPermissionGranted {
                        Button {
                            openAppSettings()
                        } label: {
                            Text("설정으로 가기")
                        }
                    }
                }
            }
        }
    }
}

private extension NotificationSettingsView {
    var notificationPermissionRow: some View {
        HStack(spacing: 0) {
            MText(
                "식사 및 운동 알림",
                style: .b3,
                color: .gray9,
                alignment: .leading
            )
            .vPadding(22)

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { store.isMealAndExerciseNotificationEnabled },
                    set: { store.send(.notificationToggleChanged($0)) }
                )
            )
            .labelsHidden()
            .disabled(!store.isNotificationPermissionGranted)
        }
        .padding(.horizontal, 24)
    }

    func openAppSettings() {
        guard let appSettingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        openURL(appSettingsURL)
    }
}
