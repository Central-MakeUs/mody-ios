//  CoreNetworkStub.swift
//  CoreNetworkTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkInterface
import Foundation

public struct CoreNetworkStub: CoreNetworkProtocol {
    private let response: (CoreNetworkEndpoint) async throws -> Data
    private let decoder: JSONDecoder
    private let responseDelay: Duration

    public init(
        decoder: JSONDecoder = JSONDecoder(),
        responseDelay: Duration = .zero,
        response: @escaping (CoreNetworkEndpoint) async throws -> Data
    ) {
        self.decoder = decoder
        self.responseDelay = responseDelay
        self.response = response
    }

    public func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        if responseDelay > .zero {
            try await Task.sleep(for: responseDelay)
        }
        let data = try await response(endpoint)
        return try decoder.decode(Response.self, from: data)
    }
}
