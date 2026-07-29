//
//  CameraPermissionInterface.swift
//  CoreCameraInterface
//
//  Created by 김동준 on 7/20/26.
//

public protocol CameraPermissionInterface {
    func isCameraPermissionNotDetermined() -> Bool
    func isCameraPermissionGranted() -> Bool
    func requestCameraPermission() async -> Bool
}
