//
//  SignInAnalyticsUseCaseStub.swift
//  SignInTesting
//
//  Created by 김동준 on 10/1/26.
//

import CoreAnalyticsInterface

public struct SignInAnalyticsUseCaseStub: AnalyticsUseCaseProtocol {
    public init() {}

    public func setUserID(_ userID: String) {}
    public func setUserNickname(_ nickname: String) {}
    public func reset() {}
    public func log(_ event: AmplitudeLogEvent) {}
    public func viewDidLoad(screenName: String) {}
}
