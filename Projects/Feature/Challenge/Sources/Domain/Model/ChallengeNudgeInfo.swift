//
//  ChallengeNudgeInfo.swift
//  Challenge
//
//  Created by 김동준 on 8/3/26.
//

public enum ChallengeNudgeButtonStatus: String, Equatable {
    case available = "AVAILABLE"
    case nudged = "NUDGED"
    case recorded = "RECORDED"
}

public struct ChallengeNudgeInfo: Equatable {
    public let memberId: Int
    public let nickname: String
    public let profileImageUrl: String
    public let recordedToday: Bool
    public let buttonStatus: ChallengeNudgeButtonStatus

    public init(
        memberId: Int,
        nickname: String,
        profileImageUrl: String,
        recordedToday: Bool,
        buttonStatus: ChallengeNudgeButtonStatus
    ) {
        self.memberId = memberId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.recordedToday = recordedToday
        self.buttonStatus = buttonStatus
    }
}
