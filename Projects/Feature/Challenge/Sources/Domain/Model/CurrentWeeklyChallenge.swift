//
//  CurrentWeeklyChallenge.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

public struct CurrentWeeklyChallenge: Equatable {
    public let groupChallengeId: Int
    public let challengeId: Int
    public let title: String
    public let remainingDays: Int
    public let participantCount: Int
    public let randomParticipantNickname: String
    public let participants: [CurrentWeeklyChallengeParticipant]

    public init(
        groupChallengeId: Int,
        challengeId: Int,
        title: String,
        remainingDays: Int,
        participantCount: Int,
        randomParticipantNickname: String,
        participants: [CurrentWeeklyChallengeParticipant]
    ) {
        self.groupChallengeId = groupChallengeId
        self.challengeId = challengeId
        self.title = title
        self.remainingDays = remainingDays
        self.participantCount = participantCount
        self.randomParticipantNickname = randomParticipantNickname
        self.participants = participants
    }
}
