//
//  CameraPermissionService.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import AVFoundation
import CoreCameraInterface

public struct CameraPermissionService: CameraPermissionInterface {
    private let authorizationStatus: () -> AVAuthorizationStatus
    private let requestAccess: () async -> Bool

    public init() {
        self.init(
            authorizationStatus: { AVCaptureDevice.authorizationStatus(for: .video) },
            requestAccess: { await AVCaptureDevice.requestAccess(for: .video) }
        )
    }

    init(
        authorizationStatus: @escaping () -> AVAuthorizationStatus,
        requestAccess: @escaping () async -> Bool
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestAccess = requestAccess
    }

    public func isCameraPermissionNotDetermined() -> Bool {
        authorizationStatus() == .notDetermined
    }

    public func isCameraPermissionGranted() -> Bool {
        authorizationStatus() == .authorized
    }

    public func requestCameraPermission() async -> Bool {
        await requestAccess()
    }
}
