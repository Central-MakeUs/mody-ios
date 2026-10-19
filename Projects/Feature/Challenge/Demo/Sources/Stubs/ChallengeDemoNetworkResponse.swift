//  ChallengeDemoNetworkResponse.swift
//  ChallengeDemo
//
//  Created by 김동준 on 10/9/26.
//

import Challenge
import CommonDomain
import CoreNetworkInterface
import CoreNetworkTesting
import Foundation

extension ChallengeDemoData {
    func response(to endpoint: CoreNetworkEndpoint, scenario: ChallengeDemoScenario) throws -> Data {
        let path = endpoint.path
        var result: Any = NSNull()
        switch endpoint.method {
        case .GET where path.hasSuffix("/challenges/summary"):
            if scenario == .streakSummaryFailure { throw NetworkError.networkUnavailable }
            result = ["daysTogether": 24, "allMemberRecordedDays": 7, "hasStartedStreak": true,
                      "monthlyExerciseMinutes": 320, "monthlyCompletedChallengeCount": 3]
        case .GET where path.hasSuffix("/challenges/nudges"):
            if scenario == .streakNudgeFailure { throw NetworkError.networkUnavailable }
            let members: [[String: Any]] = scenario == .streakEmpty || scenario == .bothEmpty ? [] :
                [(2, "동규", false, "AVAILABLE"), (3, "범근", false, "NUDGED"), (4, "민수", true, "RECORDED"),
                 (5, "지훈", false, "AVAILABLE"), (6, "현우", false, "NUDGED"), (7, "준호", true, "RECORDED")].map {
                    ["memberId": $0.0, "nickname": $0.1, "profileImageUrl": "", "recordedToday": $0.2, "buttonStatus": $0.3]
                }
            result = ["members": members]
        case .POST where path.contains("/challenges/nudges/"):
            if scenario == .nudgeFailure { throw NetworkError.networkUnavailable }
        case .GET where path.hasSuffix("/challenges/step/rankings"):
            if scenario == .rankingFailure { throw NetworkError.networkUnavailable }
            if scenario == .challengeEmpty || scenario == .bothEmpty {
                throw NetworkError.serverError(code: ServerErrorCode.challenge303.code, message: nil, fallback: .notFound)
            }
            let rankings: [[String: Any]]
            if scenario == .stepCompetition || scenario == .stepLive {
                rankings = simulatedRankings(for: scenario).map {
                    ["rank": $0.rank, "memberId": $0.memberId, "nickname": $0.nickname,
                     "profileImageUrl": $0.profileImageUrl, "stepCount": $0.stepCount]
                }
            } else {
                rankings = [(1, 2, "동규", 8_200), (2, 1, "동준", stepCount), (3, 3, "범근", 1_800)].map {
                    ["rank": $0.0, "memberId": $0.1, "nickname": $0.2, "profileImageUrl": "", "stepCount": $0.3]
                }
            }
            result = ["rankings": rankings]
        case .GET where path.hasSuffix("/challenges/step/current"):
            if scenario == .statusFailure { throw NetworkError.networkUnavailable }
            let steps = scenario == .stepCompetition || scenario == .stepLive ? simulatedSelfStepCount(for: scenario) : stepCount
            result = [
                "groupChallengeId": 51, "title": (changedChallengeId == nil ? WalkChallengeRequiredGroup.seoulDaegu : .seoulIncheon).rawValue,
                "targetStepCount": 10_000, "currentStepCount": scenario == .stepCompleted ? 10_000 : steps,
                "stepCountFetchFromAt": ISO8601DateFormatter().string(from: .now),
                "challengeStatus": scenario == .stepCompleted ? "COMPLETED" : "IN_PROGRESS"
            ]
        case .PUT where path.hasSuffix("/challenges/step/records"):
            if scenario == .stepUpdateFailure { throw NetworkError.networkUnavailable }
            if scenario != .stepCompetition && scenario != .stepLive {
                let body = try CoreNetworkJSONFixture.body(of: endpoint)
                guard let steps = body["stepCount"] as? Int else { throw NetworkError.invalidResponse }
                updateStepCount(steps)
            }
        case .GET where path.hasSuffix("/challenges/step/options"):
            if scenario == .changeOptionsFailure { throw NetworkError.networkUnavailable }
            result = ["options": [
                ["challengeId": 11, "title": WalkChallengeRequiredGroup.seoulDaegu.rawValue, "departure": "서울", "destination": "대구",
                 "distanceKm": 240, "targetStepCount": 10_000, "selected": changedChallengeId == nil, "completed": false],
                ["challengeId": 12, "title": WalkChallengeRequiredGroup.seoulIncheon.rawValue, "departure": "서울", "destination": "인천",
                 "distanceKm": 30, "targetStepCount": 5_000, "selected": changedChallengeId == 12, "completed": false],
                ["challengeId": 13, "title": WalkChallengeRequiredGroup.seoulBusan.rawValue, "departure": "서울", "destination": "부산",
                 "distanceKm": 400, "targetStepCount": 20_000, "selected": false, "completed": true]
            ]]
        case .PATCH where path.hasSuffix("/challenges/step/current"):
            if scenario == .changeFailure { throw NetworkError.networkUnavailable }
            let body = try CoreNetworkJSONFixture.body(of: endpoint)
            guard let challengeID = body["challengeId"] as? Int else { throw NetworkError.invalidResponse }
            changeChallenge(to: challengeID)
        case .GET where path.hasSuffix("/challenges/weekly"):
            if scenario == .weeklyListFailure { throw NetworkError.networkUnavailable }
            let challenges: [[String: Any]] = scenario == .weeklyEmpty ? [] : [[
                "groupChallengeId": 71, "challengeId": 31, "title": "함께 걷기", "remainingDays": 0,
                "participantCount": 7, "randomParticipantNickname": "동규", "isComplete": false,
                "participants": ["동준", "동규", "범근", "민수", "지훈", "현우", "준호"].enumerated().map {
                    ["memberId": $0.offset + 1, "nickname": $0.element] as [String: Any]
                }
            ]]
            result = ["challenges": challenges]
        case .GET where path.hasPrefix("api/v1/weekly-challenges/"):
            if scenario == .weeklyDetailFailure { throw NetworkError.networkUnavailable }
            result = ["challengeId": path.split(separator: "/").last.flatMap { Int($0) } ?? -1,
                      "title": "함께 걷기", "description": "오늘의 걸음과 사진을 함께 기록해 보세요.", "remainingDays": 0]
        case .GET where path.hasSuffix("/proofs"):
            if scenario == .weeklyProofsFailure { throw NetworkError.networkUnavailable }
            var proofs: [[String: Any]] = []
            if scenario != .weeklyProofEmpty {
                proofs.append(["proofId": 91, "imageUrl": "https://demo.invalid/challenge/friend.jpg",
                               "memberId": 2, "nickname": "동규", "profileImageUrl": "https://demo.invalid/challenge/avatar/donggyu.jpg"])
                if hasCreatedProof {
                    proofs.append(["proofId": 92, "imageUrl": "https://demo.invalid/challenge/mine.jpg",
                                   "memberId": 1, "nickname": "동준", "profileImageUrl": "https://demo.invalid/challenge/avatar/dongjun.jpg"])
                }
            }
            result = ["proofs": proofs]
        case .POST where path.hasSuffix("/proofs"):
            if scenario == .weeklyProofFailure { throw NetworkError.networkUnavailable }
            createProof()
        case .POST where path.hasSuffix("/share"):
            if scenario == .weeklyShareIncomplete {
                throw NetworkError.serverError(code: ServerErrorCode.challenge306.code, message: nil, fallback: .badRequest)
            }
            if scenario == .weeklyShareFailure { throw NetworkError.networkUnavailable }
            result = ["imageUrl": "https://demo.invalid/challenge/share.jpg"]
        default:
            throw URLError(.unsupportedURL)
        }
        return try CoreNetworkJSONFixture.response(result: result)
    }
}
