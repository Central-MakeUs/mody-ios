//
//  WeeklyChallengeDetail.swift
//  Challenge
//
//  Created by 김동준 on 8/12/26.
//

public struct WeeklyChallengeDetail: Equatable {
    public let challengeId: Int
    public let title: String
    public let description: String
    public let remainingDays: Int

    public init(
        challengeId: Int,
        title: String,
        description: String,
        remainingDays: Int
    ) {
        self.challengeId = challengeId
        self.title = title
        self.description = description
        self.remainingDays = remainingDays
    }
}
