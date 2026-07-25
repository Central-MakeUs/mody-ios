//
//  NotificationRepositoryProtocol.swift
//  CoreNotificationInterface
//
//  Created by 김동준 on 7/18/26.
//

public protocol NotificationRepositoryProtocol {
    func postPushFCMToken(_ token: String, deviceID: String?) async throws -> Bool?
    func getNotifications(cursor: Int?, size: Int, allRead: Bool) async throws -> NotificationPage
    func hasUnreadNotification() async throws -> Bool
}
