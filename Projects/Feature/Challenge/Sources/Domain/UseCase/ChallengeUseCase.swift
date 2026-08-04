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
}
