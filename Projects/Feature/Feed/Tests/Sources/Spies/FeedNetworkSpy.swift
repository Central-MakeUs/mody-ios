//
//  FeedNetworkSpy.swift
//  FeedTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreNetworkInterface
@testable import Feed

final class FeedNetworkSpy: CoreNetworkProtocol {
    var result: Result<Any, Error>
    private(set) var endpoints: [CoreNetworkEndpoint] = []

    init(result: Result<Any, Error>) {
        self.result = result
    }

    func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        endpoints.append(endpoint)
        let value = try result.get()
        guard let response = value as? Response else { throw NetworkError.invalidResponse }
        return response
    }
}
