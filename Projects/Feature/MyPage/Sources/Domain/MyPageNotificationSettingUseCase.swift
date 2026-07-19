//
//  MyPageNotificationSettingUseCase.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

public struct MyPageNotificationSettingUseCase {
    private let repository: MyPageNotificationSettingRepositoryProtocol

    public init(repository: MyPageNotificationSettingRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchNotificationSettings() async throws -> NotificationSettingState {
        try await repository.getNotificationSettings()
    }

    public func updateNotificationSettings(_ notificationSetting: NotificationSettingState) async throws -> NotificationSettingState {
        try await repository.patchNotificationSettings(notificationSetting)
    }
}
