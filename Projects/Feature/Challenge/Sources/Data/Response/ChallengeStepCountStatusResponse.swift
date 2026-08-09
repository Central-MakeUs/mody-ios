//
//  ChallengeStepCountStatusResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import Foundation

struct ChallengeStepCountStatusResponse: Decodable, Equatable {
    private let groupChallengeId: Int?
    private let title: String?
    private let targetStepCount: Int?
    private let currentStepCount: Int?
    private let stepCountFetchFromAt: String?
}

extension ChallengeStepCountStatusResponse {
    func toDomain() -> ChallengeStepCountStatus? {
        guard let title,
              let title = WalkChallengeRequiredGroup(rawValue: title),
              let stepCountFetchFromAt,
              let stepCountFetchFromAt = parseISO8601Date(stepCountFetchFromAt) else {
            return nil
        }

        return ChallengeStepCountStatus(
            groupChallengeId: groupChallengeId ?? -1,
            walkChallengeGroup: title,
            targetStepCount: targetStepCount ?? 0,
            currentStepCount: currentStepCount ?? 0,
            stepCountFetchFromAt: stepCountFetchFromAt
        )
    }
}

private extension ChallengeStepCountStatusResponse {
    func parseISO8601Date(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()

        if let date = formatter.date(from: value) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: value)
    }
}
