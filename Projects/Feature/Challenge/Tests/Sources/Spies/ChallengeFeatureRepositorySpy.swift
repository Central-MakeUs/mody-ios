//  ChallengeFeatureRepositorySpy.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

import CommonDomain
@testable import Challenge

actor ChallengeFeatureRepositorySpy: ChallengeRepositoryProtocol {
    private var nudgeInfosResult: Result<[ChallengeNudgeInfo], NetworkError> = .success([])
    private var nudgeError: NetworkError?
    private var rankings: [ChallengeStepRanking] = []
    private var rankingError: NetworkError?
    private var stepStatus = ChallengeStepCountStatus(isComplete: true)
    private var stepStatusError: NetworkError?
    private var stepUpdateError: NetworkError?
    private var weeklyList: [CurrentWeeklyChallenge] = []
    private var changeOptions: [ChangableWalkChallengeModel] = []
    private var changeError: NetworkError?
    private var shareResult: Result<WeeklyChallengeShare, NetworkError> = .success(
        WeeklyChallengeShare(imageUrl: "https://example.invalid/share.jpg")
    )
    private let weeklyDetail = WeeklyChallengeDetail(
        challengeId: 7, title: "걷기", description: "함께 걷기", remainingDays: 3
    )
    private var proofs: [WeeklyChallengeImageInfo] = []
    private var proofCreateError: NetworkError?

    private(set) var summaryRequestCount = 0
    private(set) var nudgeInfoRequests: [Int] = []
    private(set) var nudgeRequests: [(groupId: Int, memberId: Int)] = []
    private(set) var rankingRequests: [Int] = []
    private(set) var statusRequests: [Int] = []
    private(set) var stepUpdates: [(groupId: Int, request: ChallengeStepCountRequest)] = []
    private(set) var weeklyListRequests: [Int] = []
    private(set) var changeListRequests: [Int] = []
    private(set) var changeRequests: [(groupId: Int, challengeId: Int)] = []
    private(set) var shareRequests: [(groupId: Int, groupChallengeId: Int)] = []
    private(set) var weeklyDetailRequests: [Int] = []
    private(set) var proofRequests: [(groupId: Int, groupChallengeId: Int)] = []
    private(set) var proofCreations: [(groupId: Int, groupChallengeId: Int, request: WeeklyChallengeProofCreateRequest)] = []

    func setNudgeInfosResult(_ result: Result<[ChallengeNudgeInfo], NetworkError>) {
        nudgeInfosResult = result
    }

    func setNudgeError(_ error: NetworkError) {
        nudgeError = error
    }

    func setStepResults(rankings: [ChallengeStepRanking], status: ChallengeStepCountStatus) {
        self.rankings = rankings
        stepStatus = status
    }

    func setShareResult(_ result: Result<WeeklyChallengeShare, NetworkError>) {
        shareResult = result
    }

    func setRankingError(_ error: NetworkError) {
        rankingError = error
    }

    func setStepStatusError(_ error: NetworkError) {
        stepStatusError = error
    }

    func setStepUpdateError(_ error: NetworkError) {
        stepUpdateError = error
    }

    func setWeeklyList(_ list: [CurrentWeeklyChallenge]) {
        weeklyList = list
    }

    func setChangeOptions(_ options: [ChangableWalkChallengeModel]) {
        changeOptions = options
    }

    func setChangeError(_ error: NetworkError) {
        changeError = error
    }

    func setProofs(_ proofs: [WeeklyChallengeImageInfo]) {
        self.proofs = proofs
    }

    func setProofCreateError(_ error: NetworkError) {
        proofCreateError = error
    }

    func getChallengeSummary(groupId: Int) async throws -> ChallengeSummary {
        summaryRequestCount += 1
        return ChallengeSummary(
            daysTogether: 10, allMemberRecordedDays: 5, hasStartedStreak: true,
            monthlyExerciseMinutes: 100, monthlyCompletedChallengeCount: 2
        )
    }

    func getChallengeNudgeInfo(groupId: Int) async throws -> [ChallengeNudgeInfo] {
        nudgeInfoRequests.append(groupId)
        return try nudgeInfosResult.get()
    }

    func postChallengeNudge(groupId: Int, memberId: Int) async throws {
        nudgeRequests.append((groupId, memberId))
        if let nudgeError { throw nudgeError }
    }

    func getChallengeStepRankings(groupId: Int) async throws -> [ChallengeStepRanking] {
        rankingRequests.append(groupId)
        if let rankingError { throw rankingError }
        return rankings
    }

    func getStepChallengeStatus(groupId: Int) async throws -> ChallengeStepCountStatus {
        statusRequests.append(groupId)
        if let stepStatusError { throw stepStatusError }
        return stepStatus
    }

    func postRecordChallengeStepCount(groupId: Int, request: ChallengeStepCountRequest) async throws {
        stepUpdates.append((groupId, request))
        if let stepUpdateError { throw stepUpdateError }
    }

    func postWeeklyChallengeShare(groupId: Int, groupChallengeId: Int) async throws -> WeeklyChallengeShare {
        shareRequests.append((groupId, groupChallengeId))
        return try shareResult.get()
    }

    func getChangableChallengeList(groupId: Int) async throws -> [ChangableWalkChallengeModel] {
        changeListRequests.append(groupId)
        return changeOptions
    }

    func patchStepChallenge(groupId: Int, challengeId: Int) async throws {
        changeRequests.append((groupId, challengeId))
        if let changeError { throw changeError }
    }

    func getCurrentWeeklyChallenge(groupId: Int) async throws -> [CurrentWeeklyChallenge] {
        weeklyListRequests.append(groupId)
        return weeklyList
    }

    func getWeeklyChallengeDetail(challengeId: Int) async throws -> WeeklyChallengeDetail {
        weeklyDetailRequests.append(challengeId)
        return weeklyDetail
    }

    func getWeeklyChallengeProofs(groupId: Int, groupChallengeId: Int) async throws -> [WeeklyChallengeImageInfo] {
        proofRequests.append((groupId, groupChallengeId))
        return proofs
    }

    func postWeeklyChallengeProof(
        groupId: Int,
        groupChallengeId: Int,
        request: WeeklyChallengeProofCreateRequest
    ) async throws {
        proofCreations.append((groupId, groupChallengeId, request))
        if let proofCreateError { throw proofCreateError }
    }
}
