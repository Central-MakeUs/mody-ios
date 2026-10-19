//  NotificationRepositorySpy.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNotificationInterface

final class NotificationRepositorySpy: NotificationRepositoryProtocol {
    var pushResult: Result<Bool?, Error> = .failure(NotificationTestError.unexpectedCall)
    var pageResult: Result<NotificationPage, Error> = .failure(NotificationTestError.unexpectedCall)
    var unreadResult: Result<Bool, Error> = .failure(NotificationTestError.unexpectedCall)
    private(set) var tokens: [(token: String, deviceID: String?)] = []
    private(set) var queries: [(cursor: Int?, size: Int, allRead: Bool)] = []
    private(set) var unreadCallCount = 0

    func postPushFCMToken(_ token: String, deviceID: String?) async throws -> Bool? {
        tokens.append((token, deviceID))
        return try pushResult.get()
    }

    func getNotifications(cursor: Int?, size: Int, allRead: Bool) async throws -> NotificationPage {
        queries.append((cursor, size, allRead))
        return try pageResult.get()
    }

    func hasUnreadNotification() async throws -> Bool {
        unreadCallCount += 1
        return try unreadResult.get()
    }
}
