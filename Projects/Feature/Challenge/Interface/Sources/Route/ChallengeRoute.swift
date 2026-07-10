//
//  ChallengeRoute.swift
//  ChallengeInterface
//
//  Created by 김동준 on 6/30/26
//

public enum ChallengeRoute: Equatable {
    case temp
}

@MainActor
public protocol ChallengeRouter: AnyObject {
    func route(from route: ChallengeRoute)
}
