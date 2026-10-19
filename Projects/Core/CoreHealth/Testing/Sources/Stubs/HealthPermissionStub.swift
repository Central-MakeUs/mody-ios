//
//  HealthPermissionStub.swift
//  CoreHealthTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreHealthInterface

public struct HealthPermissionStub: HealthPermissionInterface {
    private let shouldShowPrompt: () async -> Bool
    private let requestPermission: () async -> Bool

    public init(shouldShowPrompt: Bool, requestResult: Bool) {
        self.init(
            shouldShowPrompt: { shouldShowPrompt },
            requestPermission: { requestResult }
        )
    }

    public init(
        shouldShowPrompt: @escaping () async -> Bool,
        requestPermission: @escaping () async -> Bool
    ) {
        self.shouldShowPrompt = shouldShowPrompt
        self.requestPermission = requestPermission
    }

    public func shouldShowHealthPermissionPrompt() async -> Bool {
        await shouldShowPrompt()
    }

    public func requestHealthPermission() async -> Bool {
        await requestPermission()
    }
}
