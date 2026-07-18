//
//  NotificationUseCase.swift
//  CoreNotification
//
//  Created by 김동준 on 7/18/26.
//

import CoreNotificationInterface

public struct NotificationUseCase: NotificationUseCaseProtocol {
    private let notificationRepository: NotificationRepositoryProtocol

    public init(notificationRepository: NotificationRepositoryProtocol) {
        self.notificationRepository = notificationRepository
    }

    public func pushFCMToken(_ token: String, deviceID: String?) async -> Bool? {
        do {
            return try await notificationRepository.postPushFCMToken(
                token,
                deviceID: deviceID
            )
        } catch {
            return false
        }
    }
}
