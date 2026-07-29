//
//  NotificationRepository.swift
//  CoreNotification
//
//  Created by 김동준 on 7/18/26.
//

import CoreKeyChainStorageInterface
import CoreNotificationInterface

public struct NotificationRepository: NotificationRepositoryProtocol {
    private let notificationService: NotificationService
    let keyChainStorage: CoreKeyChainStorageInterface

    public init(
        notificationService: NotificationService,
        keyChainStorage: CoreKeyChainStorageInterface
    ) {
        self.notificationService = notificationService
        self.keyChainStorage = keyChainStorage
    }

    public func postPushFCMToken(
        _ token: String,
        deviceID: String?
    ) async throws -> Bool? {
        do {
            if try currentFCMToken() == token { return nil }
            
            let request = PushTokenRegisterRequest(
                deviceId: deviceID,
                fcmToken: token
            )

            try await notificationService.postPushFCMToken(request)
            try keyChainStorage.save(
                key: KeyChainStorageKey.fcmToken.rawValue,
                value: token
            )

            return true
        } catch {
            return false
        }
    }
    
    public func getNotifications(
        cursor: Int?,
        size: Int,
        allRead: Bool
    ) async throws -> NotificationPage {
        let response = try await notificationService.getNotifications(
            cursor: cursor,
            size: size,
            allRead: allRead
        )

        return response.toDomain()
    }

    public func hasUnreadNotification() async throws -> Bool {
        try await notificationService.getUnreadExists().toDomain()
    }
}
