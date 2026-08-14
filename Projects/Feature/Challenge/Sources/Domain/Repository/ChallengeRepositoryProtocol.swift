//
//  ChallengeRepositoryProtocol.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

public protocol ChallengeRepositoryProtocol {
    func getChallengeSummary(groupId: Int) async throws -> ChallengeSummary
    func getChallengeNudgeInfo(groupId: Int) async throws -> [ChallengeNudgeInfo]
    func postChallengeNudge(groupId: Int, memberId: Int) async throws
    func getChallengeStepRankings(groupId: Int) async throws -> [ChallengeStepRanking]
    func getStepChallengeStatus(groupId: Int) async throws -> ChallengeStepCountStatus
    func postRecordChallengeStepCount(groupId: Int, request: ChallengeStepCountRequest) async throws
    func getChangableChallengeList(groupId: Int) async throws -> [ChangableWalkChallengeModel]
    func patchStepChallenge(groupId: Int, challengeId: Int) async throws
    func getCurrentWeeklyChallenge(groupId: Int) async throws -> [CurrentWeeklyChallenge]
    func getWeeklyChallengeDetail(challengeId: Int) async throws -> WeeklyChallengeDetail
    func getWeeklyChallengeProofs(groupId: Int, groupChallengeId: Int) async throws -> [WeeklyChallengeImageInfo]
    func postWeeklyChallengeProof(
        groupId: Int,
        groupChallengeId: Int,
        request: WeeklyChallengeProofCreateRequest
    ) async throws
}
