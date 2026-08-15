//
//  ChallengeOutput.swift
//  ChallengeInterface
//
//  Created by 김동준 on 8/3/26.
//

import CommonDomain

public enum ChallengeOutput: Equatable {
    case nudgeStarted
    case nudgeSucceeded(nickname: String)
    case showAlert(NetworkError)
    case stepChallengeChanged
    case weeklyChallengeProofCreated
}

@MainActor
public protocol ChallengeOutputHandler: AnyObject {
    func handle(output: ChallengeOutput)
}
