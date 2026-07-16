//
//  MyPageRepository.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import CommonDomain
import CoreNetworkInterface

public struct MyPageRepository: MyPageRepositoryProtocol {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    public func getMyPageProfile() async throws -> MyPageProfile {
        let endpoint = MyPageEndpoint.getMyPageProfile()
        let myPageProfileResponse: CoreNetworkResponse<MyPageProfileResponse> = try await network.request(
            endpoint
        )

        guard let myPageProfile = myPageProfileResponse.result?.toDomain() else {
            throw NetworkError.invalidResponse
        }

        return myPageProfile
    }

    public func updateMyPageProfile(
        _ request: MyPageProfileUpdateRequest
    ) async throws {
        let endpoint = MyPageEndpoint.patchMyPageProfile(request: request)
        let _: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(
            endpoint
        )
    }

    public func getWeightRecord() async throws -> WeightRecord {
        let endpoint = MyPageEndpoint.getWeightHistory()
        let response: CoreNetworkResponse<WeightRecordResponse> = try await network.request(
            endpoint
        )

        guard let weightRecord = response.result?.toDomain() else {
            throw NetworkError.invalidResponse
        }

        return weightRecord
    }

    public func postRecordWeight(weightKg: Double) async throws {
        let request = WeightRecordRequest(weightKg: weightKg)
        let endpoint = MyPageEndpoint.postWeight(request: request)
        let _ : CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(
            endpoint
        )
    }
}
