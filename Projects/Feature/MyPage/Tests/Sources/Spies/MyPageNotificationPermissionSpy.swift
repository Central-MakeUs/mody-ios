//
//  MyPageNotificationPermissionSpy.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CoreNotificationInterface

final class MyPageNotificationPermissionSpy: NotificationPermissionInterface {
    var notDetermined = false
    var granted = false
    private(set) var requestCount = 0
    private(set) var grantedCheckCount = 0

    func isNotificationPermissionNotDetermined() async -> Bool { notDetermined }
    func isNotificationPermissionGranted() async -> Bool {
        grantedCheckCount += 1
        return granted
    }
    func requestNotificationPermission() async -> Bool {
        requestCount += 1
        return granted
    }
}
