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

    public func getChallengeNudgeInfo(groupId: Int) async throws -> [ChallengeNudgeInfo] {
        let endpoint = ChallengeEndpoint.getChallengeNudgeInfo(groupId: groupId)
        let response: CoreNetworkResponse<ChallengeNudgeInfoResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }

    public func postChallengeNudge(groupId: Int, memberId: Int) async throws {
        let endpoint = ChallengeEndpoint.postChallengeNudge(
            groupId: groupId,
            memberId: memberId
        )
        let _: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(endpoint)
    }
    
    public func getChallengeStepRankings(groupId: Int) async throws -> [ChallengeStepRanking] {
        let endpoint = ChallengeEndpoint.getChallengeStepRankings(groupId: groupId)
        let response: CoreNetworkResponse<ChallengeStepRankingResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }

    public func getStepChallengeStatus(groupId: Int) async throws -> ChallengeStepCountStatus {
        let endpoint = ChallengeEndpoint.getStepChallengeStatus(groupId: groupId)
        let response: CoreNetworkResponse<ChallengeStepCountStatusResponse> = try await network.request(endpoint)

        guard let result = response.result?.toDomain() else {
            throw NetworkError.invalidResponse
        }

        return result
    }

    public func postRecordChallengeStepCount(
        groupId: Int,
        request: ChallengeStepCountRequest
    ) async throws {
        let endpoint = ChallengeEndpoint.putRecordChallengeStepCount(
            groupId: groupId,
            request: request
        )
        let response: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(endpoint)

        guard response.isSuccess != false else {
            throw NetworkError.invalidResponse
        }
    }
    
    public func getChangableChallengeList(groupId: Int) async throws -> [ChangableWalkChallengeModel] {
        let endpoint = ChallengeEndpoint.getChangableChallengeList(groupId: groupId)
        let response: CoreNetworkResponse<ChangableWalkChallengeListResponse> = try await network.request(endpoint)

        guard let result = response.result?.toDomain() else {
            throw NetworkError.invalidResponse
        }

        return result
    }

    public func patchStepChallenge(groupId: Int, challengeId: Int) async throws {
        let request = StepChallengeChangeRequest(challengeId: challengeId)
        let endpoint = ChallengeEndpoint.patchStepChallenge(
            groupId: groupId,
            request: request
        )
        let response: CoreNetworkResponse<CoreNetworkEmptyResponse> = try await network.request(endpoint)

        guard response.isSuccess != false else {
            throw NetworkError.invalidResponse
        }
    }

    public func getCurrentWeeklyChallenge(groupId: Int) async throws -> [CurrentWeeklyChallenge] {
        let endpoint = ChallengeEndpoint.getCurrentWeeklyChallenge(groupId: groupId)
        let response: CoreNetworkResponse<CurrentWeeklyChallengeListResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }

    public func getWeeklyChallengeDetail(challengeId: Int) async throws -> WeeklyChallengeDetail {
        let endpoint = ChallengeEndpoint.getWeeklyChallengeDetail(challengeId: challengeId)
        let response: CoreNetworkResponse<WeeklyChallengeDetailResponse> = try await network.request(endpoint)

        guard let result = response.result else {
            throw NetworkError.invalidResponse
        }

        return result.toDomain()
    }
}
