//
//  NotificationPermissionService.swift
//  CoreNotification
//
//  Created by 김동준 on 7/18/26.
//

import CoreNotificationInterface
import UserNotifications

public struct NotificationPermissionService: NotificationPermissionInterface {
    public init() {}

    public func isNotificationPermissionNotDetermined() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .notDetermined
    }

    public func requestNotificationPermission() async -> Bool {
        do {
            _ = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound]
            )
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            return settings.authorizationStatus == .authorized
        } catch {
            return false
        }
    }
}
