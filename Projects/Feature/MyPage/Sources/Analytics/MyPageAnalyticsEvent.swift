//
//  MyPageAnalyticsEvent.swift
//  MyPage
//
//  Created by 김동준 on 9/3/26.
//

import CoreAnalyticsInterface

enum MyPageAnalyticsEvent {
    static func notificationSettingsUpdated(
        _ notificationSetting: NotificationSettingState
    ) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "notification_settings_updated",
            properties: [
                "meal_and_exercise_enabled": notificationSetting.mealAndExerciseEnabled,
                "comment_notification_enabled": notificationSetting.commentNotificationEnabled,
                "challenge_notification_enabled": notificationSetting.challengeNotificationEnabled
            ]
        )
    }

    static let healthDataSettingsOpened = AmplitudeLogEvent(
        name: "health_data_settings_opened"
    )
    static let healthAppOpenClicked = AmplitudeLogEvent(
        name: "health_settings_clicked"
    )
    static let weightRecordCreated = AmplitudeLogEvent(name: "weight_record_created")
    static let logoutSucceeded = AmplitudeLogEvent(name: "logout_succeeded")
    static let accountDeletionSucceeded = AmplitudeLogEvent(
        name: "account_deletion_succeeded"
    )
}
