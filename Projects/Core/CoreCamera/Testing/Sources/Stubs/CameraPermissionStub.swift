//  CameraPermissionStub.swift
//  CoreCameraTesting
//
//  Created by 김동준 on 10/9/26.
//

import CoreCameraInterface

public struct CameraPermissionStub: CameraPermissionInterface {
    private let isNotDetermined: Bool
    private let isGranted: Bool
    private let requestResult: Bool

    public init(isNotDetermined: Bool, isGranted: Bool, requestResult: Bool) {
        self.isNotDetermined = isNotDetermined
        self.isGranted = isGranted
        self.requestResult = requestResult
    }

    public func isCameraPermissionNotDetermined() -> Bool { isNotDetermined }
    public func isCameraPermissionGranted() -> Bool { isGranted }
    public func requestCameraPermission() async -> Bool { requestResult }
}
