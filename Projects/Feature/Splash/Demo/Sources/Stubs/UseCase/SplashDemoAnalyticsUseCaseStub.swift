//
//  SplashDemoAnalyticsUseCaseStub.swift
//  SplashDemo
//
//  Created by 김동준 on 9/29/26.
//

import CoreAnalyticsInterface

struct SplashDemoAnalyticsUseCaseStub: AnalyticsUseCaseProtocol {
    func setUserID(_ userID: String) {}
    func setUserNickname(_ nickname: String) {}
    func reset() {}
    func log(_ event: AmplitudeLogEvent) {}
    func viewDidLoad(screenName: String) {}
}
