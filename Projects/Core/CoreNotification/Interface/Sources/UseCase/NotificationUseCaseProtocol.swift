//
//  NotificationUseCaseProtocol.swift
//  CoreNotificationInterface
//
//  Created by 김동준 on 7/18/26.
//

public protocol NotificationUseCaseProtocol {
    func pushFCMToken(_ token: String, deviceID: String) async -> Bool?
    func deleteFCMToken(deviceID: String) async throws
}
