//
//  ChangableWalkChallengeListResponse.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

struct ChangableWalkChallengeListResponse: Decodable, Equatable {
    private let options: [ChangableWalkChallengeResponse]?
}

private struct ChangableWalkChallengeResponse: Decodable, Equatable {
    private let challengeId: Int?
    private let title: String?
    private let departure: String?
    private let destination: String?
    private let distanceKm: Double?
    private let targetStepCount: Int?
    private let selected: Bool?
    private let completed: Bool?
}

extension ChangableWalkChallengeListResponse {
    func toDomain() -> [ChangableWalkChallengeModel]? {
        let options = options ?? []
        let challenges = options.compactMap { $0.toDomain() }

        return challenges
    }
}

private extension ChangableWalkChallengeResponse {
    func toDomain() -> ChangableWalkChallengeModel? {
        guard let title,
              let walkChallengeGroup = WalkChallengeRequiredGroup(rawValue: title),
              let departure,
              let departure = RegionType(rawValue: departure),
              let destination,
              let destination = RegionType(rawValue: destination) else {
            return nil
        }

        return ChangableWalkChallengeModel(
            challengeId: challengeId ?? -1,
            walkChallengeGroup: walkChallengeGroup,
            departure: departure,
            destination: destination,
            distanceKm: distanceKm ?? 0,
            targetStepCount: targetStepCount ?? 0,
            selected: selected ?? false,
            completed: completed ?? false
        )
    }
}
