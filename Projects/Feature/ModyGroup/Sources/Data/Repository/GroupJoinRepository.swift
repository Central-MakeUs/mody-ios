//
//  GroupJoinRepository.swift
//  ModyGroup
//
//  Created by 김동준 on 7/10/26
//

import CommonDomain
import CoreNetworkInterface

public struct GroupJoinRepository: GroupJoinRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func postJoinGroup(request: GroupJoinRequest) async throws {
        let endpoint = GroupJoinEndpoint.postJoin(request: request)
        let response: CoreNetworkResponse<GroupJoinResponse> = try await network.request(endpoint)

        guard response.result != nil else {
            throw NetworkError.invalidResponse
        }
    }
}
