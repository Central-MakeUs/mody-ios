//  ChallengeRepositorySpy.swift
//  ChallengeTests
//
//  Created by 김동준 on 10/6/26.
//

@testable import Challenge

final class ChallengeRepositorySpy: ChallengeRepositoryProtocol {
    var changableChallengeList: [ChangableWalkChallengeModel] = []
    var weeklyChallengeProofs: [WeeklyChallengeImageInfo] = []
    var weeklyChallengeDetail = WeeklyChallengeDetail(
        challengeId: -1,
        title: "",
        description: "",
        remainingDays: 0
    )

    private(set) var changableChallengeGroupId: Int?
    private(set) var changedGroupId: Int?
    private(set) var changedChallengeId: Int?
    private(set) var recordedGroupId: Int?
    private(set) var recordedRequest: ChallengeStepCountRequest?
    private(set) var weeklyChallengeDetailId: Int?
    private(set) var weeklyChallengeProofsGroupId: Int?
    private(set) var weeklyChallengeProofsGroupChallengeId: Int?

    func getChallengeSummary(groupId: Int) async throws -> ChallengeSummary {
        fatalError("Not used in these tests")
    }

    func getChallengeNudgeInfo(groupId: Int) async throws -> [ChallengeNudgeInfo] {
        fatalError("Not used in these tests")
    }

    func postChallengeNudge(groupId: Int, memberId: Int) async throws {
        fatalError("Not used in these tests")
    }

    func getChallengeStepRankings(groupId: Int) async throws -> [ChallengeStepRanking] {
        fatalError("Not used in these tests")
    }

    func getStepChallengeStatus(groupId: Int) async throws -> ChallengeStepCountStatus {
        fatalError("Not used in these tests")
    }

    func getChangableChallengeList(groupId: Int) async throws -> [ChangableWalkChallengeModel] {
        changableChallengeGroupId = groupId
        return changableChallengeList
    }

    func patchStepChallenge(groupId: Int, challengeId: Int) async throws {
        changedGroupId = groupId
        changedChallengeId = challengeId
    }

    func getCurrentWeeklyChallenge(groupId: Int) async throws -> [CurrentWeeklyChallenge] {
        fatalError("Not used in these tests")
    }

    func getWeeklyChallengeDetail(challengeId: Int) async throws -> WeeklyChallengeDetail {
        weeklyChallengeDetailId = challengeId
        return weeklyChallengeDetail
    }

    func getWeeklyChallengeProofs(
        groupId: Int,
        groupChallengeId: Int
    ) async throws -> [WeeklyChallengeImageInfo] {
        weeklyChallengeProofsGroupId = groupId
        weeklyChallengeProofsGroupChallengeId = groupChallengeId
        return weeklyChallengeProofs
    }

    func postWeeklyChallengeProof(
        groupId: Int,
        groupChallengeId: Int,
        request: WeeklyChallengeProofCreateRequest
    ) async throws {
        fatalError("Not used in these tests")
    }

    func postWeeklyChallengeShare(
        groupId: Int,
        groupChallengeId: Int
    ) async throws -> WeeklyChallengeShare {
        fatalError("Not used in these tests")
    }

    func postRecordChallengeStepCount(
        groupId: Int,
        request: ChallengeStepCountRequest
    ) async throws {
        recordedGroupId = groupId
        recordedRequest = request
    }
}
