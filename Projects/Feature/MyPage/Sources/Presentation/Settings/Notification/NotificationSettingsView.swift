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
            .mLoading(isPresent: store.isLoading)
    }

    private var notificationSettingBody: some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "알림 설정",
                onBackTap: { store.send(.backButtonTapped) }
            )
            ScrollView {
                VStack(spacing: 0) {
                    notificationPermissionRow(
                        title: "코멘트 알림",
                        contents: "친구들이 내 기록에 남긴 댓글 알림을 받아요.",
                        toggleValue: store.notificationSetting.commentNotificationEnabled,
                        needDivider: true,
                        onTap: { store.send(.notificationToggleChanged(.comment, isOn: $0)) }
                    )

                    notificationPermissionRow(
                        title: "챌린지 알림",
                        contents: "챌린지와 관련된 모든 알림을 받아요.",
                        toggleValue: store.notificationSetting.challengeNotificationEnabled,
                        needDivider: true,
                        onTap: { store.send(.notificationToggleChanged(.challenge, isOn: $0)) }
                    )

                    notificationPermissionRow(
                        title: "식사 및 운동 알림",
                        toggleValue: store.notificationSetting.mealAndExerciseEnabled,
                        onTap: { store.send(.notificationToggleChanged(.mealAndExercise, isOn: $0)) }
                    )

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
    func notificationPermissionRow(
        title: String,
        contents: String? = nil,
        toggleValue: Bool,
        needDivider: Bool = false,
        onTap: @escaping (Bool) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                MText(
                    title,
                    style: .b3,
                    color: .gray9,
                    alignment: .leading
                )

                if let contents = contents {
                    MText(
                        contents,
                        style: .c2,
                        color: .gray6,
                        alignment: .leading
                    )
                    .padding(.top, 4)
                }
            }

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { toggleValue },
                    set: { onTap($0) }
                )
            )
            .labelsHidden()
            .disabled(!store.isNotificationPermissionGranted)
        }
        .height(contents == nil ? 68 : 89)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            if needDivider {
                Color.gray1
                    .height(1)
            }
        }
    }

    func openAppSettings() {
        guard let appSettingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        openURL(appSettingsURL)
    }
}
