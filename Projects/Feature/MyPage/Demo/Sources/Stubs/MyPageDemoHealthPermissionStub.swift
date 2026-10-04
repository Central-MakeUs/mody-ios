//
//  MyPageDemoHealthPermissionStub.swift
//  MyPageDemo
//
//  Created by 김동준 on 10/4/26.
//

import CoreHealthInterface

struct MyPageDemoHealthPermissionStub: HealthPermissionInterface {
    private let shouldRequest: Bool

    init(shouldRequest: Bool) {
        self.shouldRequest = shouldRequest
    }

    func shouldShowHealthPermissionPrompt() async -> Bool { shouldRequest }
    func requestHealthPermission() async -> Bool { true }
}
