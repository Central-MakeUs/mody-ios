//
//  MessagingDelegate+.swift
//  Mody
//
//  Created by 김동준 on 7/18/26.
//

import FirebaseMessaging
import ModyLogger

extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let fcmToken = fcmToken else { return }
        ModyLogger.debug("Firebase registration token: \(String(describing: fcmToken))")
        registerFCMToken(fcmToken)
    }
}
