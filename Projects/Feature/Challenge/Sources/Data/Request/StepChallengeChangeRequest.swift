//  StepChallengeChangeRequest.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

struct StepChallengeChangeRequest: Encodable, Equatable {
    private let challengeId: Int

    init(challengeId: Int) {
        self.challengeId = challengeId
    }
}
