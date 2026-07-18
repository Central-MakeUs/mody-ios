//
//  NotificationRepositoryProtocol.swift
//  CoreNotificationInterface
//
//  Created by 김동준 on 7/18/26.
//

public protocol NotificationRepositoryProtocol {
    func postPushFCMToken(_ token: String, deviceID: String) async throws -> Bool?
    func deleteFCMToken(deviceID: String) async throws
}
