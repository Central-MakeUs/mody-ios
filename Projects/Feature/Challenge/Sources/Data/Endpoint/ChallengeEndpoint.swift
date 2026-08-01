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
}
