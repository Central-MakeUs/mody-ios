//
//  NotificationSettingsView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import Base
import Combine
import ComposableArchitecture
import DesignSystem
import SwiftUI
import UIKit

public struct NotificationSettingsView: View {
    @Environment(\.openURL) private var openURL
    @Bindable private var store: StoreOf<NotificationSettingsFeature>

    public init(store: StoreOf<NotificationSettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        GeometryReader { proxy in
            notificationSettingBody(contentWidth: proxy.size.width - 48)
        }
        .background(Color.systemWhite)
        .onAppear { store.send(.onAppear) }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification
            )
        ) { _ in
            store.send(.checkNotificationPermission)
        }
        .sheet(
            isPresented: $store.isTimeSheetPresented,
            onDismiss: { store.send(.timeSheetDismissed) }
        ) {
            ReminderExerciseTimeSheet(
                date: $store.timeSheetDate,
                locale: store.locale,
                calendar: store.calendar,
                timeZone: store.timeZone
            ) {
                store.send(.timeSheetConfirmTapped)
            }
        }
        .mLoading(isPresent: store.isLoading)
        .mAlert(store.scope(state: \.alertState, action: \.alertAction)) {
            alertView
        }
    }

    private func notificationSettingBody(contentWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: "알림 설정",
                onBackTap: { store.send(.backButtonTapped) }
            )
            ScrollView {
                VStack(spacing: 0) {
                    notificationRows

                    if store.notificationSetting.mealAndExerciseEnabled {
                        scheduleEditor(width: contentWidth)
                            .padding(.horizontal, 24)
                            .padding(.top, 0)
                            .padding(.bottom, 24)
                            .disabled(!store.isNotificationPermissionGranted)
                    }

                    if !store.isNotificationPermissionGranted {
                        MButton(
                            "설정으로 가기",
                            style: .black,
                            verticalPadding: 13,
                            maxWidth: .infinity
                        ) {
                            openAppSettings()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }

            if store.notificationSetting.mealAndExerciseEnabled {
                saveButton
            }
        }
        .animation(
            .easeInOut(duration: 0.18),
            value: store.notificationSetting.mealAndExerciseEnabled
        )
    }
}

private extension NotificationSettingsView {
    var notificationRows: some View {
        VStack(spacing: 0) {
            if !store.isPhaseOne {
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
            }

            notificationPermissionRow(
                title: "식사 및 운동 알림",
                toggleValue: store.notificationSetting.mealAndExerciseEnabled,
                onTap: {
                    store.send(
                        .notificationToggleChanged(.mealAndExercise, isOn: $0),
                        animation: .easeInOut(duration: 0.18)
                    )
                }
            )
        }
    }

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

                if let contents {
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
}

private extension NotificationSettingsView {
    func scheduleEditor(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            ReminderMealSection(
                meals: store.meals,
                mealHours: store.mealHours,
                skippedMeals: store.skippedMeals,
                expandedMeal: store.expandedMeal,
                onSkipTapped: { meal in
                    store.send(.mealSkipTapped(meal))
                },
                onDropdownTapped: { meal in
                    store.send(.mealDropdownTapped(meal), animation: .easeInOut(duration: 0.18))
                },
                onHourTapped: { meal, hour in
                    store.send(
                        .mealHourTapped(meal: meal, hour: hour),
                        animation: .easeInOut(duration: 0.18)
                    )
                }
            )
            .padding(.bottom, 36)

            ReminderExerciseSection(
                width: width,
                weekdays: store.weekdays,
                selectedWeekdays: store.selectedWeekdays,
                schedules: store.sortedExerciseSchedules,
                calendar: store.calendar,
                onWeekdayTapped: { weekday in
                    store.send(.weekdayTapped(weekday), animation: .easeInOut(duration: 0.18))
                },
                onScheduleTapped: { weekday in
                    store.send(.exerciseScheduleTapped(weekday))
                },
                onSameTimeTapped: {
                    store.send(.sameExerciseTimeTapped)
                }
            )
        }
    }

    var saveButton: some View {
        MButton(
            "저장하기",
            style: store.isSaveButtonEnabled ? .primary : .gray,
            isDisabled: !store.isSaveButtonEnabled,
            horizontalPadding: 0,
            verticalPadding: 13,
            maxWidth: .infinity
        ) {
            store.send(.saveButtonTapped)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Color.systemWhite)
    }

    func openAppSettings() {
        guard let appSettingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        openURL(appSettingsURL)
    }
}

private extension NotificationSettingsView {
    @ViewBuilder
    var alertView: some View {
        if let alertCase = store.alertCase {
            switch alertCase {
            case .success:
                MAlertContentView(
                    title: "저장 완료",
                    contents: "식사 시간 및 운동 일정을 저장했어요.",
                    trailingButton: MAlertButton("확인") {
                        store.send(.alertAction(.dismiss))
                    }
                )
            case let .error(networkError):
                CommonErrorAlertView(networkError) {
                    store.send(.alertAction(.dismiss))
                }
            }
        }
    }
}
