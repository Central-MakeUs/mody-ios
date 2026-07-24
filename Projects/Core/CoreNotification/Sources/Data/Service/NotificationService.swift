//
//  NotificationService.swift
//  CoreNotification
//
//  Created by 김동준 on 7/18/26.
//

import CoreNetworkInterface

public struct NotificationService {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    func postPushFCMToken(_ request: PushTokenRegisterRequest) async throws {
        let endpoint = NotificationEndpoint.postPushFCMToken(request)
        let _: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(endpoint)
    }
    
    func getNotifications(
        cursor: Int?,
        size: Int,
        allRead: Bool
    ) async throws -> NotificationListResponse {
        let endpoint = NotificationEndpoint.getNotifications(
            cursor: cursor,
            size: size,
            allRead: allRead
        )
        let response: CoreNetworkResponse<NotificationListResponse> = try await network.request(
            endpoint
        )

        guard let result = response.result else {
            throw NotificationServiceError.emptyResponse
        }

        return result
    }

    func getUnreadExists() async throws -> NotificationUnReadExistsResponse {
        let endpoint = NotificationEndpoint.getUnreadExists()
        let response: CoreNetworkResponse<NotificationUnReadExistsResponse> = try await network.request(
            endpoint
        )

        guard let result = response.result else {
            throw NotificationServiceError.emptyResponse
        }

        return result
    }
}

private enum NotificationServiceError: Error {
    case emptyResponse
}
