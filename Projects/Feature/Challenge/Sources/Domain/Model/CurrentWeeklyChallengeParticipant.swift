//
//  CurrentWeeklyChallengeParticipant.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

public struct CurrentWeeklyChallengeParticipant: Equatable {
    public let memberId: Int
    public let nickname: String
    public let profileImageUrl: String?

    public init(
        memberId: Int,
        nickname: String,
        profileImageUrl: String?
    ) {
        self.memberId = memberId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
    }
}
