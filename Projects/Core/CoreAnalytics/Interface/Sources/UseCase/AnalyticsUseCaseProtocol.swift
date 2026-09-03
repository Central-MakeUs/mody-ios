//
//  AnalyticsUseCaseProtocol.swift
//  CoreAnalyticsInterface
//
//  Created by 김동준 on 8/17/26.
//

public protocol AnalyticsUseCaseProtocol {
    func setUserID(_ userID: String)
    func setUserNickname(_ nickname: String)
    func reset()
    func log(_ event: AmplitudeLogEvent)
    func viewDidLoad(screenName: String)
}
