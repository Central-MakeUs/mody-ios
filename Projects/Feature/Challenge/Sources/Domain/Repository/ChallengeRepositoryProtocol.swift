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
}
