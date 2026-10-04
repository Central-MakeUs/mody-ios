//
//  OnBoardingAnalyticsUseCaseStub.swift
//  OnBoardingTesting
//
//  Created by 김동준 on 10/4/26.
//

import CoreAnalyticsInterface

public struct OnBoardingAnalyticsUseCaseStub: AnalyticsUseCaseProtocol {
    public init() {}

    public func setUserID(_ userID: String) {}
    public func setUserNickname(_ nickname: String) {}
    public func reset() {}
    public func log(_ event: AmplitudeLogEvent) {}
    public func viewDidLoad(screenName: String) {}
}
