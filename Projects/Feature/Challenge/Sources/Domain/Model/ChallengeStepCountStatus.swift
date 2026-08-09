//
//  ChallengeStepCountStatus.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import Foundation

public struct ChallengeStepCountStatus: Equatable {
    public let groupChallengeId: Int
    public let title: WalkChallengeRequiredGroup
    public let targetStepCount: Int
    public let currentStepCount: Int
    public let stepCountFetchFromAt: Date

    public init(
        groupChallengeId: Int,
        title: WalkChallengeRequiredGroup,
        targetStepCount: Int,
        currentStepCount: Int,
        stepCountFetchFromAt: Date
    ) {
        self.groupChallengeId = groupChallengeId
        self.title = title
        self.targetStepCount = targetStepCount
        self.currentStepCount = currentStepCount
        self.stepCountFetchFromAt = stepCountFetchFromAt
    }
}
