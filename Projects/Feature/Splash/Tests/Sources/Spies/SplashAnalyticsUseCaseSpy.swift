//
//  SplashAnalyticsUseCaseSpy.swift
//  SplashTests
//
//  Created by 김동준 on 9/29/26.
//

import CoreAnalyticsInterface

final class SplashAnalyticsUseCaseSpy: AnalyticsUseCaseProtocol {
    private(set) var userIDs: [String] = []
    private(set) var nicknames: [String] = []
    private(set) var events: [AmplitudeLogEvent] = []

    func setUserID(_ userID: String) {
        userIDs.append(userID)
    }

    func setUserNickname(_ nickname: String) {
        nicknames.append(nickname)
    }

    func reset() {}

    func log(_ event: AmplitudeLogEvent) {
        events.append(event)
    }

    func viewDidLoad(screenName: String) {}
}
