//  ChallengeDemoData.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/9/26.
//

import Challenge
import Foundation

actor ChallengeDemoData {
    private(set) var changedChallengeId: Int?
    private(set) var hasCreatedProof = false
    private(set) var stepCount = 2_500
    private var simulationTick = 0

    private let members: [(id: Int, name: String, steps: Int)] = [
        (2, "동규", 8_200), (1, "동준", 8_100), (3, "범근", 8_000),
        (4, "민수", 7_900), (5, "지훈", 7_800), (6, "현우", 7_700),
        (7, "준호", 7_600)
    ]

    func advance(to tick: Int) {
        simulationTick = max(simulationTick, tick)
    }

    func simulatedRankings(for scenario: ChallengeDemoScenario) -> [ChallengeStepRanking] {
        let scores = members.map { member -> (id: Int, name: String, steps: Int) in
            var steps = member.steps
            if simulationTick > 0 {
                for round in 1...simulationTick {
                    steps += 80 + member.id * 10
                    if scenario == .stepCompetition,
                       member.id == [3, 5, 1, 7, 2, 6, 4][(round - 1) % 7] {
                        steps += 3_000 + round * 300
                    }
                }
            }
            return (member.id, member.name, steps)
        }
        return scores.sorted { $0.steps > $1.steps }.enumerated().map { index, member in
            ChallengeStepRanking(
                rank: index + 1, memberId: member.id, nickname: member.name,
                profileImageUrl: "", stepCount: member.steps
            )
        }
    }

    func simulatedSelfStepCount(for scenario: ChallengeDemoScenario) -> Int {
        simulatedRankings(for: scenario).first(where: { $0.memberId == 1 })?.stepCount ?? stepCount
    }

    func changeChallenge(to id: Int) { changedChallengeId = id }
    func createProof() { hasCreatedProof = true }
    func updateStepCount(_ value: Int) { stepCount = value }
}
