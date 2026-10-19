//  NotificationNetworkSpy.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkInterface
import CoreNetworkTesting
import Foundation

final class NotificationNetworkSpy: CoreNetworkProtocol {
    var response: Data = Data()
    var error: Error?
    private(set) var endpoints: [CoreNetworkEndpoint] = []

    func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        endpoints.append(endpoint)
        let stub = CoreNetworkStub { _ in
            if let error = self.error { throw error }
            return self.response
        }
        return try await stub.request(endpoint)
    }
}
