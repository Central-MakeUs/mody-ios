//  AuthNetworkSpy.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CoreNetworkInterface
import Foundation

final class AuthNetworkSpy: CoreNetworkProtocol {
    private let responseJSON: String
    var error: Error?
    var onRequest: ((CoreNetworkEndpoint) -> Void)?
    private(set) var endpoints: [CoreNetworkEndpoint] = []

    init(responseJSON: String = "{}") {
        self.responseJSON = responseJSON
    }

    func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        endpoints.append(endpoint)
        onRequest?(endpoint)
        if let error { throw error }
        return try JSONDecoder().decode(Response.self, from: Data(responseJSON.utf8))
    }
}
