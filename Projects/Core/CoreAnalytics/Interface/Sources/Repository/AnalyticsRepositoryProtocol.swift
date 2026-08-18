//
//  AnalyticsRepositoryProtocol.swift
//  CoreAnalyticsInterface
//
//  Created by 김동준 on 8/17/26.
//

public protocol AnalyticsRepositoryProtocol {
    func setUserID(_ userID: String?)
    func log(_ event: AmplitudeLogEvent)
    func viewDidLoad(screenName: String)
}
