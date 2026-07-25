//
//  FeedRepository.swift
//  Feed
//
//  Created by 김동준 on 7/25/26.
//

import CommonDomain
import CoreNetworkInterface

public struct FeedRepository: FeedRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func getActivityCalendar(groupId: Int, baseDate: String) async throws -> FeedActivityCalendarModel {
        let endpoint = FeedEndpoint.getActivityCalendar(
            groupId: groupId,
            baseDate: baseDate
        )
        let response: CoreNetworkResponse<FeedActivityCalendarResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }
}
