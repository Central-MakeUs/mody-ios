//
//  GroupNetworkSpy.swift
//  ModyGroupTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreNetworkInterface

final class GroupNetworkSpy: CoreNetworkProtocol {
    private let result: Result<Any, Error>
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
