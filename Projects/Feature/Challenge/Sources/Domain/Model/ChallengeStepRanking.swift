//
//  ChallengeStepRanking.swift
//  Challenge
//
//  Created by 김동준 on 8/6/26.
//

public struct ChallengeStepRanking: Equatable {
    public let rank: Int
    public let memberId: Int
    public let nickname: String
    public let profileImageUrl: String
    public let stepCount: Int

    public init(
        rank: Int,
        memberId: Int,
        nickname: String,
        profileImageUrl: String,
        stepCount: Int
    ) {
        self.rank = rank
        self.memberId = memberId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.stepCount = stepCount
    }
}
