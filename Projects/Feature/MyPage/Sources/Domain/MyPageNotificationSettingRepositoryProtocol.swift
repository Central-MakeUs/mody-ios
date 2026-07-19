//
//  MyPageNotificationSettingRepositoryProtocol.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

public protocol MyPageNotificationSettingRepositoryProtocol {
    func getNotificationSettings() async throws -> NotificationSettingState
    func patchNotificationSettings(_ notificationSetting: NotificationSettingState) async throws -> NotificationSettingState
}
