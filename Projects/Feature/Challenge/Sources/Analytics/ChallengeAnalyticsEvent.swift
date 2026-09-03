//
//  ChallengeAnalyticsEvent.swift
//  Challenge
//
//  Created by 김동준 on 9/3/26.
//

import CoreAnalyticsInterface

enum ChallengeAnalyticsEvent {
    static let nudgeSucceeded = AmplitudeLogEvent(name: "nudge_succeeded")
    static let weeklyChallengeProofCreated = AmplitudeLogEvent(
        name: "weekly_challenge_created"
    )
    static let stepRefreshClicked = AmplitudeLogEvent(name: "step_refresh_clicked")
    static let challengeShareClicked = AmplitudeLogEvent(name: "challenge_share_clicked")
}
