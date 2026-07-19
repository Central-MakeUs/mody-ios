//
//  NotificationSettingRequest.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

struct NotificationSettingRequest: Encodable, Equatable {
    let recordReminderEnabled: Bool
    let commentNotificationEnabled: Bool
    let challengeNotificationEnabled: Bool

    init(state: NotificationSettingState) {
        self.recordReminderEnabled = state.mealAndExerciseEnabled
        self.commentNotificationEnabled = state.commentNotificationEnabled
        self.challengeNotificationEnabled = state.challengeNotificationEnabled
    }
}
