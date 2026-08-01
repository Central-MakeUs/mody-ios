//
//  ChallengeSummaryResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

struct ChallengeSummaryResponse: Decodable, Equatable {
    let daysTogether: Int?
    let allMemberRecordedDays: Int?
    let monthlyExerciseMinutes: Int?
    let monthlyCompletedChallengeCount: Int?
}

extension ChallengeSummaryResponse {
    func toDomain() -> ChallengeSummary {
        ChallengeSummary(
            daysTogether: daysTogether ?? 0,
            allMemberRecordedDays: allMemberRecordedDays ?? 0,
            monthlyExerciseMinutes: monthlyExerciseMinutes ?? 0,
            monthlyCompletedChallengeCount: monthlyCompletedChallengeCount ?? 0
        )
    }
}
