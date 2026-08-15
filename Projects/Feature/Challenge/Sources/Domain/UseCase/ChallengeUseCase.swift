//
//  ChallengeUseCase.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

public struct ChallengeUseCase {
    private let repository: ChallengeRepositoryProtocol

    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }

    public func fetchChallengeSummary(groupId: Int) async throws -> ChallengeSummary {
        try await repository.getChallengeSummary(groupId: groupId)
    }

    public func fetchChallengeNudgeInfo(groupId: Int) async throws -> [ChallengeNudgeInfo] {
        try await repository.getChallengeNudgeInfo(groupId: groupId)
    }

    public func nudgeMember(groupId: Int, memberId: Int) async throws {
        try await repository.postChallengeNudge(groupId: groupId, memberId: memberId)
    }
    
    public func fetchChallengeStepRankings(groupId: Int) async throws -> [ChallengeStepRanking] {
        try await repository.getChallengeStepRankings(groupId: groupId)
    }

    public func fetchStepChallengeStatus(groupId: Int) async throws -> ChallengeStepCountStatus {
        try await repository.getStepChallengeStatus(groupId: groupId)
    }

    public func updateChallengeStepCount(groupId: Int, request: ChallengeStepCountRequest) async throws {
        try await repository.postRecordChallengeStepCount(groupId: groupId, request: request)
    }
    
    public func fetchChangableChallengeList(groupId: Int) async throws -> [ChangableWalkChallengeModel] {
        try await repository.getChangableChallengeList(groupId: groupId)
    }

    public func changeStepChallenge(groupId: Int, challengeId: Int) async throws {
        try await repository.patchStepChallenge(
            groupId: groupId,
            challengeId: challengeId
        )
    }

    public func fetchCurrentWeeklyChallenge(groupId: Int) async throws -> [CurrentWeeklyChallenge] {
        try await repository.getCurrentWeeklyChallenge(groupId: groupId)
    }

    public func fetchWeeklyChallengeDetail(challengeId: Int) async throws -> WeeklyChallengeDetail {
        try await repository.getWeeklyChallengeDetail(challengeId: challengeId)
    }

    public func fetchWeeklyChallengeProofs(groupId: Int, groupChallengeId: Int) async throws -> [WeeklyChallengeImageInfo] {
        try await repository.getWeeklyChallengeProofs(groupId: groupId, groupChallengeId: groupChallengeId)
    }

    public func createWeeklyChallengeProof(
        groupId: Int,
        groupChallengeId: Int,
        request: WeeklyChallengeProofCreateRequest
    ) async throws {
        try await repository.postWeeklyChallengeProof(
            groupId: groupId,
            groupChallengeId: groupChallengeId,
            request: request
        )
    }

    public func shareWeeklyChallenge(
        groupId: Int,
        groupChallengeId: Int
    ) async throws -> WeeklyChallengeShare {
        try await repository.postWeeklyChallengeShare(
            groupId: groupId,
            groupChallengeId: groupChallengeId
        )
    }
}
