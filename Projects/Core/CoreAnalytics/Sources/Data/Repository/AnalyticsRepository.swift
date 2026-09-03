//
//  AnalyticsRepository.swift
//  CoreAnalytics
//
//  Created by 김동준 on 8/17/26.
//

import CoreAnalyticsInterface

public struct AnalyticsRepository: AnalyticsRepositoryProtocol {
    private let amplitudeService: AmplitudeService

    public init(amplitudeService: AmplitudeService) {
        self.amplitudeService = amplitudeService
    }

    public func setUserID(_ userID: String) {
        amplitudeService.setUserID(userID)
    }

    public func setUserNickname(_ nickname: String) {
        amplitudeService.setUserNickname(nickname)
    }

    public func reset() {
        amplitudeService.reset()
    }

    public func log(_ event: AmplitudeLogEvent) {
        amplitudeService.log(event)
    }

    public func viewDidLoad(screenName: String) {
        amplitudeService.viewDidLoad(screenName: screenName)
    }
}
