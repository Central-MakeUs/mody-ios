//
//  ChallengeStepRankingResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/6/26.
//

struct ChallengeStepRankingResponse: Decodable, Equatable {
    private let rankings: [ChallengeStepRankingItemResponse]?
}

private struct ChallengeStepRankingItemResponse: Decodable, Equatable {
    private let rank: Int?
    private let memberId: Int?
    private let nickname: String?
    private let profileImageUrl: String?
    private let stepCount: Int?
}

extension ChallengeStepRankingResponse {
    func toDomain() -> [ChallengeStepRanking] {
        (rankings ?? []).map { $0.toDomain() }
    }
}

private extension ChallengeStepRankingItemResponse {
    func toDomain() -> ChallengeStepRanking {
        ChallengeStepRanking(
            rank: rank ?? 0,
            memberId: memberId ?? -1,
            nickname: nickname ?? "",
            profileImageUrl: profileImageUrl ?? "",
            stepCount: stepCount ?? 0
        )
    }
}
