//
//  ChallengeRepositoryProtocol.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

public protocol ChallengeRepositoryProtocol {
    func getChallengeSummary(groupId: Int) async throws -> ChallengeSummary
}
