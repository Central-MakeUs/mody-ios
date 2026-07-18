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
}
