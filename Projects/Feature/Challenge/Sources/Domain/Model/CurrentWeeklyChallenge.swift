//
//  CurrentWeeklyChallenge.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

public struct CurrentWeeklyChallenge: Equatable {
    public let groupChallengeId: Int
    public let title: String
    public let remainingDays: Int
    public let participantCount: Int
    public let randomParticipantNickname: String
    public let participants: [CurrentWeeklyChallengeParticipant]
    public let isComplete: Bool

    public init(
        groupChallengeId: Int,
        title: String,
        remainingDays: Int,
        participantCount: Int,
        randomParticipantNickname: String,
        participants: [CurrentWeeklyChallengeParticipant],
        isComplete: Bool
    ) {
        self.groupChallengeId = groupChallengeId
        self.title = title
        self.remainingDays = remainingDays
        self.participantCount = participantCount
        self.randomParticipantNickname = randomParticipantNickname
        self.participants = participants
        self.isComplete = isComplete
    }
}
