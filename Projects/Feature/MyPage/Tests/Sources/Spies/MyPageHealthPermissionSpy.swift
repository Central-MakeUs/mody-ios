//
//  MyPageHealthPermissionSpy.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CoreHealthInterface

final class MyPageHealthPermissionSpy: HealthPermissionInterface {
    var shouldRequest = false
    private(set) var checkCount = 0
    private(set) var requestCount = 0

    func shouldShowHealthPermissionPrompt() async -> Bool {
        checkCount += 1
        return shouldRequest
    }
    func requestHealthPermission() async -> Bool {
        requestCount += 1
        return true
    }
}
