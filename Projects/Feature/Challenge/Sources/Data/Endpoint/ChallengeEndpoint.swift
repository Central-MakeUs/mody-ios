//
//  ChallengeEndpoint.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import CoreNetworkInterface

enum ChallengeEndpoint {
    static func getChallengeSummary(groupId: Int) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/summary",
            method: .GET
        )
    }

    static func getChallengeNudgeInfo(groupId: Int) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/nudges",
            method: .GET
        )
    }

    static func postChallengeNudge(groupId: Int, memberId: Int) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/nudges/\(memberId)",
            method: .POST
        )
    }
    
    static func getChallengeStepRankings(groupId: Int) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/step/rankings",
            method: .GET
        )
    }

    static func getStepChallengeStatus(groupId: Int) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/step/current",
            method: .GET
        )
    }

    static func putRecordChallengeStepCount(
        groupId: Int,
        request: ChallengeStepCountRequest
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/step/records",
            method: .PUT,
            bodyParameters: request
        )
    }
    
    static func getChangableChallengeList(groupId: Int) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/step/options",
            method: .GET
        )
    }

    static func patchStepChallenge(
        groupId: Int,
        request: StepChallengeChangeRequest
    ) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/step/current",
            method: .PATCH,
            bodyParameters: request
        )
    }

    static func getCurrentWeeklyChallenge(groupId: Int) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: "api/v1/groups/\(groupId)/challenges/weekly",
            method: .GET
        )
    }
}
