//
//  ChallengeNudgeInfo.swift
//  Challenge
//
//  Created by 김동준 on 8/3/26.
//

public struct ChallengeNudgeInfo: Equatable {
    public let memberId: Int
    public let nickname: String
    public let profileImageUrl: String
    public let recordedToday: Bool

    public init(
        memberId: Int,
        nickname: String,
        profileImageUrl: String,
        recordedToday: Bool
    ) {
        self.memberId = memberId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.recordedToday = recordedToday
    }
}
