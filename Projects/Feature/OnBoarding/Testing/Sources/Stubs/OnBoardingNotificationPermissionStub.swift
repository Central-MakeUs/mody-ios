//
//  OnBoardingNotificationPermissionStub.swift
//  OnBoardingTesting
//
//  Created by 김동준 on 10/4/26.
//

import CoreNotificationInterface

public struct OnBoardingNotificationPermissionStub: NotificationPermissionInterface {
    private let requestResult: Bool

    public init(requestResult: Bool) {
        self.requestResult = requestResult
    }

    public func isNotificationPermissionNotDetermined() async -> Bool { true }
    public func isNotificationPermissionGranted() async -> Bool { requestResult }
    public func requestNotificationPermission() async -> Bool { requestResult }
}
