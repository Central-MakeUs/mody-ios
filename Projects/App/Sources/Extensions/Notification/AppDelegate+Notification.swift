//
//  AppDelegate+Notification.swift
//  Mody
//
//  Created by 김동준 on 7/18/26.
//

import FirebaseMessaging
import ModyLogger
import UIKit

extension AppDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        ModyLogger.debug("[APNs] device token: \(token)")
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        ModyLogger.debug("[APNs] registration error: \(error)")
    }
}

extension AppDelegate {
    func registerFCMToken(_ fcmToken: String) {
        let deviceID = UIDevice.current.identifierForVendor?.uuidString

        Task { [notificationUseCase, deviceID] in
            _ = await notificationUseCase.pushFCMToken(
                fcmToken,
                deviceID: deviceID
            )
        }
    }
}
