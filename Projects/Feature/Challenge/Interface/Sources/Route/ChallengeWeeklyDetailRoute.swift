//
//  ChallengeWeeklyDetailRoute.swift
//  ChallengeInterface
//
//  Created by 김동준 on 8/12/26.
//

public enum ChallengeWeeklyDetailRoute: Equatable {
    case back
}

@MainActor
public protocol ChallengeWeeklyDetailRouter: AnyObject {
    func route(from route: ChallengeWeeklyDetailRoute)
}
