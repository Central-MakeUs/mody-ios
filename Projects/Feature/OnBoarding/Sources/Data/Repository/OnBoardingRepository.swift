//
//  OnBoardingRepository.swift
//  OnBoarding
//
//  Created by 김동준 on 7/8/26
//

import CoreNetworkInterface
import CommonDomain

public struct OnBoardingRepository: OnBoardingRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func postSetupOnBoardingProfileInfo(request: OnBoardingProfileRequest) async throws {
        let endpoint = OnBoardingEndpoint.postProfile(request: request)
        let response: CoreNetworkResponse<OnBoardingProfileResponse> = try await network.request(
            endpoint
        )

        guard response.result != nil else {
            throw NetworkError.invalidResponse
        }
    }
}
