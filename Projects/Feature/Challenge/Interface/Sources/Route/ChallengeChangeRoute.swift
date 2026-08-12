//
//  ChallengeChangeRoute.swift
//  ChallengeInterface
//
//  Created by 김동준 on 8/9/26.
//

public enum ChallengeChangeRoute: Equatable {
    case back
}

@MainActor
public protocol ChallengeChangeRouter: AnyObject {
    func route(from route: ChallengeChangeRoute)
}
