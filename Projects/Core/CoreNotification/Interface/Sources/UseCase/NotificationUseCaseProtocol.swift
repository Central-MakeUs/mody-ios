//
//  NotificationUseCaseProtocol.swift
//  CoreNotificationInterface
//
//  Created by 김동준 on 7/18/26.
//

public protocol NotificationUseCaseProtocol {
    func pushFCMToken(_ token: String, deviceID: String?) async -> Bool?
    func getNotifications(cursor: Int?, size: Int, allRead: Bool) async throws -> NotificationPage
    func hasUnreadNotification() async throws -> Bool
}
