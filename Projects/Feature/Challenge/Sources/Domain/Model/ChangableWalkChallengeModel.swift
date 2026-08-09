//
//  ChangableWalkChallengeModel.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

public struct ChangableWalkChallengeModel: Equatable {
    public let challengeId: Int
    public let walkChallengeGroup: WalkChallengeRequiredGroup
    public let departure: RegionType
    public let destination: RegionType
    public let distanceKm: Double
    public let targetStepCount: Int
    public let selected: Bool
    public let completed: Bool

    public init(
        challengeId: Int,
        walkChallengeGroup: WalkChallengeRequiredGroup,
        departure: RegionType,
        destination: RegionType,
        distanceKm: Double,
        targetStepCount: Int,
        selected: Bool,
        completed: Bool
    ) {
        self.challengeId = challengeId
        self.walkChallengeGroup = walkChallengeGroup
        self.departure = departure
        self.destination = destination
        self.distanceKm = distanceKm
        self.targetStepCount = targetStepCount
        self.selected = selected
        self.completed = completed
    }
}
