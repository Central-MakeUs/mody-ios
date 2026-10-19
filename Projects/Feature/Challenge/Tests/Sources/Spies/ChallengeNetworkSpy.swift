//  ChallengeNetworkSpy.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import CoreNetworkInterface
import Foundation

final class ChallengeNetworkSpy: CoreNetworkProtocol {
    var json = "{}"
    var error: Error?
    private(set) var endpoints: [CoreNetworkEndpoint] = []

    func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        endpoints.append(endpoint)
        if let error { throw error }
        return try JSONDecoder().decode(Response.self, from: Data(json.utf8))
    }
}
