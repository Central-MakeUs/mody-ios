//
//  AmplitudeService.swift
//  CoreAnalytics
//
//  Created by 김동준 on 8/17/26.
//

import AmplitudeSwift
import CoreAnalyticsInterface
import Foundation

public final class AmplitudeService {
    private let amplitude: Amplitude?

    public init(apiKey: String?) {
        guard let apiKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines),
              !apiKey.isEmpty else {
            amplitude = nil
            return
        }

        amplitude = Amplitude(
            configuration: Configuration(
                apiKey: apiKey,
                autocapture: [.sessions, .appLifecycles, .screenViews],
                enableAutoCaptureRemoteConfig: false,
                enableDiagnostics: false
            )
        )
    }

    func setUserID(_ userID: String?) {
        guard let amplitude else { return }

        guard let userID else {
            amplitude.reset()
            amplitude.setDeviceId(deviceId: UUID().uuidString)
            return
        }

        amplitude.setUserId(userId: userID)
    }

    func log(_ event: AmplitudeLogEvent) {
        amplitude?.track(
            eventType: event.name,
            eventProperties: event.properties
        )
    }

    func viewDidLoad(screenName: String) {
        amplitude?.track(
            eventType: EventName.viewDidLoad,
            eventProperties: [PropertyKey.screenName: screenName]
        )
    }
}

private extension AmplitudeService {
    enum EventName {
        static let viewDidLoad = "view_did_load"
    }

    enum PropertyKey {
        static let screenName = "screen_name"
    }
}
