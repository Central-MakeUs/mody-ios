//
//  ChallengeAnalyticsEvent.swift
//  Challenge
//
//  Created by 김동준 on 9/3/26.
//

import CoreAnalyticsInterface
import CoreCameraInterface

enum ChallengeAnalyticsEvent {
    static func cameraButtonClicked(
        button: CameraCaptureButton
    ) -> AmplitudeLogEvent {
        AmplitudeLogEvent(
            name: "camera_button_clicked",
            properties: [
                "source": "weekly_challenge",
                "button": button.rawValue
            ]
        )
    }

    static let nudgeSucceeded = AmplitudeLogEvent(name: "nudge_succeeded")
    static let weeklyChallengeProofCreated = AmplitudeLogEvent(
        name: "weekly_challenge_created"
    )
    static let stepRefreshClicked = AmplitudeLogEvent(name: "step_refresh_clicked")
    static let challengeShareClicked = AmplitudeLogEvent(name: "challenge_share_clicked")
}
