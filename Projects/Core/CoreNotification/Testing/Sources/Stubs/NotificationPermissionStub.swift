//  NotificationPermissionStub.swift
//  CoreNotificationTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreNotificationInterface

public struct NotificationPermissionStub: NotificationPermissionInterface {
    private let isNotDetermined: () async -> Bool
    private let isGranted: () async -> Bool
    private let requestPermission: () async -> Bool

    public init(isNotDetermined: Bool, isGranted: Bool, requestResult: Bool) {
        self.init(
            isNotDetermined: { isNotDetermined },
            isGranted: { isGranted },
            requestPermission: { requestResult }
        )
    }

    public init(
        isNotDetermined: @escaping () async -> Bool,
        isGranted: @escaping () async -> Bool,
        requestPermission: @escaping () async -> Bool
    ) {
        self.isNotDetermined = isNotDetermined
        self.isGranted = isGranted
        self.requestPermission = requestPermission
    }

    public func isNotificationPermissionNotDetermined() async -> Bool {
        await isNotDetermined()
    }

    public func isNotificationPermissionGranted() async -> Bool {
        await isGranted()
    }

    public func requestNotificationPermission() async -> Bool {
        await requestPermission()
    }
}
