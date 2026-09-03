//
//  ModyGroupAnalyticsEvent.swift
//  ModyGroup
//
//  Created by 김동준 on 9/3/26.
//

import CoreAnalyticsInterface

enum ModyGroupAnalyticsEvent {
    static func membershipSucceeded(action: String) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "group_membership_succeeded",
            properties: ["action": action]
        )
    }

    static let inviteShareSucceeded = AmplitudeLogEvent(
        name: "group_invite_share_succeeded"
    )
}
