//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  Mody
//
//  Created by 김동준 on 7/18/26.
//

import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
