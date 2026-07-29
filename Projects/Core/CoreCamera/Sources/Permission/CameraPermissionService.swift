//
//  CameraPermissionService.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import AVFoundation
import CoreCameraInterface

public struct CameraPermissionService: CameraPermissionInterface {
    public init() {}

    public func isCameraPermissionNotDetermined() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }

    public func isCameraPermissionGranted() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    public func requestCameraPermission() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
}
