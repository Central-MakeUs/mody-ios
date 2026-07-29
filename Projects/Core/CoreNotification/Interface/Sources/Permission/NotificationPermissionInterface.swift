//
//  NotificationPermissionInterface.swift
//  CoreNotificationInterface
//
//  Created by 김동준 on 7/18/26.
//

public protocol NotificationPermissionInterface {
    func isNotificationPermissionNotDetermined() async -> Bool
    func isNotificationPermissionGranted() async -> Bool
    func requestNotificationPermission() async -> Bool
}
