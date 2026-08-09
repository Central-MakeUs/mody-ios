//
//  ChallengeStepCountStatus.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import Foundation

public struct ChallengeStepCountStatus: Equatable {
    public let groupChallengeId: Int
    public let walkChallengeGroup: WalkChallengeRequiredGroup
    public let targetStepCount: Int
    public let currentStepCount: Int
    public let stepCountFetchFromAt: Date

    public init(
        groupChallengeId: Int,
        walkChallengeGroup: WalkChallengeRequiredGroup,
        targetStepCount: Int,
        currentStepCount: Int,
        stepCountFetchFromAt: Date
    ) {
        self.groupChallengeId = groupChallengeId
        self.walkChallengeGroup = walkChallengeGroup
        self.targetStepCount = targetStepCount
        self.currentStepCount = currentStepCount
        self.stepCountFetchFromAt = stepCountFetchFromAt
    }
}
