//
//  FeedRepository.swift
//  Feed
//
//  Created by 김동준 on 7/21/26
//

import CommonDomain
import CoreNetworkInterface

public struct FeedRepository: FeedRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func getRecords(
        groupId: Int,
        date: String,
        cursor: Int?,
        size: Int
    ) async throws -> FeedRecordPage {
        let endpoint = FeedEndpoint.getRecords(
            groupId: groupId,
            date: date,
            cursor: cursor,
            size: size
        )
        let response: CoreNetworkResponse<FeedRecordListResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }
}
