//
//  GroupRepository.swift
//  ModyGroup
//
//  Created by 김동준 on 7/11/26
//

import CommonDomain
import CoreNetworkInterface

public struct GroupRepository: GroupRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func postCreateGroup(request: GroupCreateRequest) async throws -> String {
        let endpoint = GroupEndpoint.postCreate(request: request)
        let response: CoreNetworkResponse<GroupCreateResponse> = try await network.request(endpoint)

        guard let code = response.result?.code, !code.isEmpty else {
            throw NetworkError.invalidResponse
        }

        return code
    }

    public func postJoinGroup(request: GroupJoinRequest) async throws {
        let endpoint = GroupEndpoint.postJoin(request: request)
        let response: CoreNetworkResponse<GroupJoinResponse> = try await network.request(endpoint)

        guard response.result != nil else {
            throw NetworkError.invalidResponse
        }
    }
}
