//
//  WeeklyChallengeDetailResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

struct WeeklyChallengeDetailResponse: Decodable, Equatable {
    private let challengeId: Int?
    private let title: String?
    private let description: String?
    private let remainingDays: Int?

    func toDomain() -> WeeklyChallengeDetail {
        WeeklyChallengeDetail(
            challengeId: challengeId ?? -1,
            title: title ?? "",
            description: description ?? "",
            remainingDays: remainingDays ?? 0
        )
    }
}
