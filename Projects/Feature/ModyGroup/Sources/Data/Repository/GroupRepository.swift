//
//  GroupRepository.swift
//  ModyGroup
//
//  Created by 김동준 on 7/11/26
//

import CommonDomain
import CoreNetworkInterface
import ModyGroupInterface

public struct GroupRepository: GroupRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func createGroup(name: String) async throws -> String {
        let request = GroupCreateRequest(name: name)
        let endpoint = GroupEndpoint.postCreate(request: request)
        let response: CoreNetworkResponse<GroupCreateResponse> = try await network.request(endpoint)

        guard let code = response.result?.code, !code.isEmpty else {
            throw NetworkError.invalidResponse
        }

        return code
    }

    public func joinGroup(code: String) async throws {
        let request = GroupJoinRequest(code: code)
        let endpoint = GroupEndpoint.postJoin(request: request)
        let response: CoreNetworkResponse<GroupJoinResponse> = try await network.request(endpoint)

        guard response.result != nil else {
            throw NetworkError.invalidResponse
        }
    }

    public func getGroups() async throws -> [GroupModel] {
        let endpoint = GroupEndpoint.getGroups()
        let response: CoreNetworkResponse<GroupListResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }

    public func deleteGroup(groupId: Int) async throws {
        let endpoint = GroupEndpoint.deleteGroup(groupId: groupId)
        let _: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(endpoint)
    }
}
