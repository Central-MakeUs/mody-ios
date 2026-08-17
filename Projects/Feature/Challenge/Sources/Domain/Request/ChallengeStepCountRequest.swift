//
//  ChallengeStepCountRequest.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

public struct ChallengeStepCountRequest: Encodable, Equatable {
    public let recordedOn: String
    public let stepCount: Int

    public init(recordedOn: String, stepCount: Int) {
        self.recordedOn = recordedOn
        self.stepCount = stepCount
    }
}
