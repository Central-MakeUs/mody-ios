//
//  OnBoardingAnalyticsSpy.swift
//  OnBoardingTests
//
//  Created by 김동준 on 10/4/26.
//

import CoreAnalyticsInterface

final class OnBoardingAnalyticsSpy: AnalyticsUseCaseProtocol {
    private(set) var userIDs: [String] = []
    private(set) var nicknames: [String] = []

    func setUserID(_ userID: String) { userIDs.append(userID) }
    func setUserNickname(_ nickname: String) { nicknames.append(nickname) }
    func reset() {}
    func log(_ event: AmplitudeLogEvent) {}
    func viewDidLoad(screenName: String) {}
}
