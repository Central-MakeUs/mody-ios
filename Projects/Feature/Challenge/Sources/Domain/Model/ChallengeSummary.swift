//
//  ChallengeSummary.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

public struct ChallengeSummary: Equatable {
    public let daysTogether: Int
    public let allMemberRecordedDays: Int
    public let hasStartedStreak: Bool
    public let monthlyExerciseMinutes: Int
    public let monthlyCompletedChallengeCount: Int

    public init(
        daysTogether: Int,
        allMemberRecordedDays: Int,
        hasStartedStreak: Bool,
        monthlyExerciseMinutes: Int,
        monthlyCompletedChallengeCount: Int
    ) {
        self.daysTogether = daysTogether
        self.allMemberRecordedDays = allMemberRecordedDays
        self.hasStartedStreak = hasStartedStreak
        self.monthlyExerciseMinutes = monthlyExerciseMinutes
        self.monthlyCompletedChallengeCount = monthlyCompletedChallengeCount
    }
}
