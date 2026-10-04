//
//  SignInAnalyticsUseCaseSpy.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

import CoreAnalyticsInterface

final class SignInAnalyticsUseCaseSpy: AnalyticsUseCaseProtocol {
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
