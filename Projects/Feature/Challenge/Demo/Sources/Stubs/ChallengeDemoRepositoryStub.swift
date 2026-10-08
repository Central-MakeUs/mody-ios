//
//  ChallengeDemoRepositoryStub.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/5/26.
//

import Challenge
import CommonDomain
import Foundation

actor ChallengeDemoData {
    var changedChallengeId: Int?
    var hasCreatedProof = false
    var stepCount = 2_500
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

struct ChallengeDemoRepositoryStub: ChallengeRepositoryProtocol {
    private let scenario: ChallengeDemoScenario
    private let data: ChallengeDemoData

    init(scenario: ChallengeDemoScenario, data: ChallengeDemoData) {
        self.scenario = scenario
        self.data = data
    }

    func getChallengeSummary(groupId: Int) async throws -> ChallengeSummary {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .streakSummaryFailure { throw NetworkError.networkUnavailable }
        return ChallengeSummary(
            daysTogether: 24,
            allMemberRecordedDays: 7,
            hasStartedStreak: true,
            monthlyExerciseMinutes: 320,
            monthlyCompletedChallengeCount: 3
        )
    }

    func getChallengeNudgeInfo(groupId: Int) async throws -> [ChallengeNudgeInfo] {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .streakNudgeFailure { throw NetworkError.networkUnavailable }
        if scenario == .streakEmpty || scenario == .bothEmpty { return [] }
        return [
            ChallengeNudgeInfo(memberId: 2, nickname: "동규", profileImageUrl: "", recordedToday: false, buttonStatus: .available),
            ChallengeNudgeInfo(memberId: 3, nickname: "범근", profileImageUrl: "", recordedToday: false, buttonStatus: .nudged),
            ChallengeNudgeInfo(memberId: 4, nickname: "민수", profileImageUrl: "", recordedToday: true, buttonStatus: .recorded),
            ChallengeNudgeInfo(memberId: 5, nickname: "지훈", profileImageUrl: "", recordedToday: false, buttonStatus: .available),
            ChallengeNudgeInfo(memberId: 6, nickname: "현우", profileImageUrl: "", recordedToday: false, buttonStatus: .nudged),
            ChallengeNudgeInfo(memberId: 7, nickname: "준호", profileImageUrl: "", recordedToday: true, buttonStatus: .recorded)
        ]
    }

    func postChallengeNudge(groupId: Int, memberId: Int) async throws {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .nudgeFailure { throw NetworkError.networkUnavailable }
    }

    func getChallengeStepRankings(groupId: Int) async throws -> [ChallengeStepRanking] {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .rankingFailure { throw NetworkError.networkUnavailable }
        if scenario == .challengeEmpty || scenario == .bothEmpty {
            throw NetworkError.serverError(
                code: ServerErrorCode.challenge303.code,
                message: nil,
                fallback: .notFound
            )
        }
        if scenario == .stepCompetition || scenario == .stepLive {
            return await data.simulatedRankings(for: scenario)
        }
        let steps = await data.stepCount
        return [
            ChallengeStepRanking(rank: 1, memberId: 2, nickname: "동규", profileImageUrl: "", stepCount: 8_200),
            ChallengeStepRanking(rank: 2, memberId: 1, nickname: "동준", profileImageUrl: "", stepCount: steps),
            ChallengeStepRanking(rank: 3, memberId: 3, nickname: "범근", profileImageUrl: "", stepCount: 1_800)
        ]
    }

    func getStepChallengeStatus(groupId: Int) async throws -> ChallengeStepCountStatus {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .statusFailure { throw NetworkError.networkUnavailable }
        let steps = scenario == .stepCompetition || scenario == .stepLive
            ? await data.simulatedSelfStepCount(for: scenario)
            : await data.stepCount
        let changed = await data.changedChallengeId
        return ChallengeStepCountStatus(
            groupChallengeId: 51,
            walkChallengeGroup: changed == nil ? .seoulDaegu : .seoulIncheon,
            targetStepCount: 10_000,
            currentStepCount: scenario == .stepCompleted ? 10_000 : steps,
            stepCountFetchFromAt: .now,
            isComplete: scenario == .stepCompleted
        )
    }

    func postRecordChallengeStepCount(groupId: Int, request: ChallengeStepCountRequest) async throws {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .stepUpdateFailure { throw NetworkError.networkUnavailable }
        if scenario != .stepCompetition && scenario != .stepLive {
            await data.updateStepCount(request.stepCount)
        }
    }

    func getChangableChallengeList(groupId: Int) async throws -> [ChangableWalkChallengeModel] {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .changeOptionsFailure { throw NetworkError.networkUnavailable }
        let changed = await data.changedChallengeId
        return [
            ChangableWalkChallengeModel(
                challengeId: 11, walkChallengeGroup: .seoulDaegu, departure: .seoul,
                destination: .daegu, distanceKm: 240, targetStepCount: 10_000,
                selected: changed == nil, completed: false
            ),
            ChangableWalkChallengeModel(
                challengeId: 12, walkChallengeGroup: .seoulIncheon, departure: .seoul,
                destination: .incheon, distanceKm: 30, targetStepCount: 5_000,
                selected: changed == 12, completed: false
            ),
            ChangableWalkChallengeModel(
                challengeId: 13, walkChallengeGroup: .seoulBusan, departure: .seoul,
                destination: .busan, distanceKm: 400, targetStepCount: 20_000,
                selected: false, completed: true
            )
        ]
    }

    func patchStepChallenge(groupId: Int, challengeId: Int) async throws {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .changeFailure { throw NetworkError.networkUnavailable }
        await data.changeChallenge(to: challengeId)
    }

    func getCurrentWeeklyChallenge(groupId: Int) async throws -> [CurrentWeeklyChallenge] {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .weeklyListFailure { throw NetworkError.networkUnavailable }
        if scenario == .weeklyEmpty { return [] }
        return [
            CurrentWeeklyChallenge(
                groupChallengeId: 71, challengeId: 31, title: "함께 걷기", remainingDays: 0,
                participantCount: 7, randomParticipantNickname: "동규",
                participants: [
                    CurrentWeeklyChallengeParticipant(memberId: 1, nickname: "동준", profileImageUrl: nil),
                    CurrentWeeklyChallengeParticipant(memberId: 2, nickname: "동규", profileImageUrl: nil),
                    CurrentWeeklyChallengeParticipant(memberId: 3, nickname: "범근", profileImageUrl: nil),
                    CurrentWeeklyChallengeParticipant(memberId: 4, nickname: "민수", profileImageUrl: nil),
                    CurrentWeeklyChallengeParticipant(memberId: 5, nickname: "지훈", profileImageUrl: nil),
                    CurrentWeeklyChallengeParticipant(memberId: 6, nickname: "현우", profileImageUrl: nil),
                    CurrentWeeklyChallengeParticipant(memberId: 7, nickname: "준호", profileImageUrl: nil)
                ],
                isComplete: false
            )
        ]
    }

    func getWeeklyChallengeDetail(challengeId: Int) async throws -> WeeklyChallengeDetail {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .weeklyDetailFailure { throw NetworkError.networkUnavailable }
        return WeeklyChallengeDetail(
            challengeId: challengeId, title: "함께 걷기",
            description: "오늘의 걸음과 사진을 함께 기록해 보세요.", remainingDays: 0
        )
    }

    func getWeeklyChallengeProofs(groupId: Int, groupChallengeId: Int) async throws -> [WeeklyChallengeImageInfo] {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .weeklyProofsFailure { throw NetworkError.networkUnavailable }
        if scenario == .weeklyProofEmpty { return [] }
        var proofs = [
            WeeklyChallengeImageInfo(
                proofId: 91, imageUrl: "https://demo.invalid/challenge/friend.jpg",
                imageCropRegion: nil, memberId: 2, nickname: "동규",
                profileImageUrl: "https://demo.invalid/challenge/avatar/donggyu.jpg"
            )
        ]
        if await data.hasCreatedProof {
            proofs.append(WeeklyChallengeImageInfo(
                proofId: 92, imageUrl: "https://demo.invalid/challenge/mine.jpg",
                imageCropRegion: nil, memberId: 1, nickname: "동준",
                profileImageUrl: "https://demo.invalid/challenge/avatar/dongjun.jpg"
            ))
        }
        return proofs
    }

    func postWeeklyChallengeProof(
        groupId: Int,
        groupChallengeId: Int,
        request: WeeklyChallengeProofCreateRequest
    ) async throws {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .weeklyProofFailure { throw NetworkError.networkUnavailable }
        await data.createProof()
    }

    func postWeeklyChallengeShare(groupId: Int, groupChallengeId: Int) async throws -> WeeklyChallengeShare {
        try await Task.sleep(for: .milliseconds(500))
        if scenario == .weeklyShareIncomplete {
            throw NetworkError.serverError(
                code: ServerErrorCode.challenge306.code,
                message: nil,
                fallback: .badRequest
            )
        }
        if scenario == .weeklyShareFailure { throw NetworkError.networkUnavailable }
        return WeeklyChallengeShare(imageUrl: "https://demo.invalid/challenge/share.jpg")
    }
}
