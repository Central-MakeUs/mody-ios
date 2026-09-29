//
//  SplashAnalyticsUseCaseStub.swift
//  SplashTesting
//
//  Created by 김동준 on 9/29/26.
//

import CoreAnalyticsInterface

public struct SplashAnalyticsUseCaseStub: AnalyticsUseCaseProtocol {
    public init() {}

    public func setUserID(_ userID: String) {}
    public func setUserNickname(_ nickname: String) {}
    public func reset() {}
    public func log(_ event: AmplitudeLogEvent) {}
    public func viewDidLoad(screenName: String) {}
}
