//
//  ChallengeInput.swift
//  ChallengeInterface
//
//  Created by 김동준 on 8/1/26.
//

import CommonDomain

public enum ChallengeInput {
    case selectedGroupUpdated(GroupModel?)
}

@MainActor
public protocol ChallengeInputHandler: AnyObject {
    func handle(input: ChallengeInput)
}
