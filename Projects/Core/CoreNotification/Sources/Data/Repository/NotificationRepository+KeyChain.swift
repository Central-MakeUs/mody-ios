//
//  NotificationRepository+KeyChain.swift
//  CoreNotification
//
//  Created by 김동준 on 7/18/26.
//

import CoreKeyChainStorageInterface

extension NotificationRepository {
    func currentFCMToken() throws -> String? {
        do {
            let token: String = try keyChainStorage.read(
                key: KeyChainStorageKey.fcmToken.rawValue
            )
            return token
        } catch {
            return nil
        }
    }
}
