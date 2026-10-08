//
//  OnBoardingPermissionStub.swift
//  OnBoardingTesting
//
//  Created by 김동준 on 10/4/26.
//

import CoreHealthInterface
import CoreNotificationInterface

public struct OnBoardingPermissionStub: NotificationPermissionInterface, HealthPermissionInterface {
    private let shouldPromptForHealth: Bool
    private let requestResult: Bool

    public init(shouldPromptForHealth: Bool, requestResult: Bool) {
        self.shouldPromptForHealth = shouldPromptForHealth
        self.requestResult = requestResult
    }

    public func isNotificationPermissionNotDetermined() async -> Bool { true }
    public func isNotificationPermissionGranted() async -> Bool { requestResult }
    public func requestNotificationPermission() async -> Bool { requestResult }

    public func shouldShowHealthPermissionPrompt() async -> Bool { shouldPromptForHealth }
    public func requestHealthPermission() async -> Bool { requestResult }
}
