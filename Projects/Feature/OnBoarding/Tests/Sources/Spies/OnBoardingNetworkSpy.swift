//
//  OnBoardingNetworkSpy.swift
//  OnBoardingTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreNetworkInterface
@testable import OnBoarding

final class OnBoardingNetworkSpy: CoreNetworkProtocol {
    private let result: Result<CoreNetworkResponse<OnBoardingProfileResponse>, Error>
    private(set) var endpoints: [CoreNetworkEndpoint] = []

    init(result: Result<CoreNetworkResponse<OnBoardingProfileResponse>, Error>) {
        self.result = result
    }

    func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        endpoints.append(endpoint)
        let response = try result.get()
        guard let response = response as? Response else { throw NetworkError.invalidResponse }
        return response
    }
}
