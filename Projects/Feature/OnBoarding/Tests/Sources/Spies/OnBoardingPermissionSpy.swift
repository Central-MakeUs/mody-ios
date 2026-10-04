//
//  OnBoardingPermissionSpy.swift
//  OnBoardingTests
//
//  Created by 김동준 on 10/4/26.
//

import CoreCameraInterface
import CoreHealthInterface
import CoreNotificationInterface

final class OnBoardingPermissionSpy: CameraPermissionInterface, NotificationPermissionInterface, HealthPermissionInterface {
    private let shouldRequestHealth: Bool
    private(set) var calls: [String] = []

    init(shouldRequestHealth: Bool = true) {
        self.shouldRequestHealth = shouldRequestHealth
    }

    func isCameraPermissionNotDetermined() -> Bool { true }
    func isCameraPermissionGranted() -> Bool { false }
    func isNotificationPermissionNotDetermined() async -> Bool { true }
    func isNotificationPermissionGranted() async -> Bool { false }

    func requestNotificationPermission() async -> Bool {
        calls.append("notification")
        return false
    }

    func requestCameraPermission() async -> Bool {
        calls.append("camera")
        return false
    }

    func shouldShowHealthPermissionPrompt() async -> Bool {
        calls.append("healthCheck")
        return shouldRequestHealth
    }

    func requestHealthPermission() async -> Bool {
        calls.append("health")
        return false
    }
}
