//
//  CoreNetworkSpy.swift
//  SplashTests
//
//  Created by 김동준 on 10/4/26.
//

import CoreNetworkInterface
import SplashTesting

final class CoreNetworkSpy: CoreNetworkProtocol {
    private(set) var requestedEndpoints: [CoreNetworkEndpoint] = []

    func request<Response: Decodable>(
        _ endpoint: CoreNetworkEndpoint
    ) async throws -> Response {
        requestedEndpoints.append(endpoint)
        guard let response = CoreNetworkResponse<[String: String]>() as? Response else {
            throw SplashTestingError.expectedFailure
        }
        return response
    }
}
