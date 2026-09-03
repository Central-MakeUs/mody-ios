//
//  MainAnalyticsEvent.swift
//  Main
//
//  Created by 김동준 on 9/3/26.
//

import CoreAnalyticsInterface
import CoreNotificationInterface

enum MainAnalyticsEvent {
    static let notificationCenterOpened = AmplitudeLogEvent(
        name: "notification_opened"
    )
    static let challengeShareSucceeded = AmplitudeLogEvent(
        name: "challenge_share_succeeded"
    )

    static func notificationNavigationSelected(
        type: NotificationType
    ) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "notification_navigation_selected",
            properties: ["notification_type": type.rawValue]
        )
    }
}
