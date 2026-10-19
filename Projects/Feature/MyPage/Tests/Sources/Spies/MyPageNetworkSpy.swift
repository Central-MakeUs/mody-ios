//
//  MyPageNetworkSpy.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import Foundation
import CoreNetworkInterface

final class MyPageNetworkSpy: CoreNetworkProtocol {
    var json = "{}"
    var error: Error?
    private(set) var endpoints: [CoreNetworkEndpoint] = []

    func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        endpoints.append(endpoint)
        if let error { throw error }
        return try JSONDecoder().decode(Response.self, from: Data(json.utf8))
    }
}
