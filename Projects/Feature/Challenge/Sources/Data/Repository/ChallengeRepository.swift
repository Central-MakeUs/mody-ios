//
//  ChallengeRepository.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import CommonDomain
import CoreNetworkInterface

public struct ChallengeRepository: ChallengeRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func getChallengeSummary(groupId: Int) async throws -> ChallengeSummary {
        let endpoint = ChallengeEndpoint.getChallengeSummary(groupId: groupId)
        let response: CoreNetworkResponse<ChallengeSummaryResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }
}
