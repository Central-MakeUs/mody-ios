//  CameraSessionHardwareSpy.swift
//  CoreCameraTests
//
//  Created by 김동준 on 10/9/26.
//

import AVFoundation

@testable import CoreCamera

/// Tests는 주입한 sessionQueue.sync 이후에만 기록을 읽습니다.
final class CameraSessionHardwareSpy: CameraCaptureSessionHardware {
    let session = AVCaptureSession()
    private var running = false
    var onIsRunningRead: (@Sendable () -> Void)?
    var isRunning: Bool {
        get {
            onIsRunningRead?()
            return running
        }
        set { running = newValue }
    }
    var availablePhotoCodecTypes: [AVVideoCodecType] = [.jpeg]
    var configureResult = true
    var onConfigure: (@Sendable () -> Void)?
    var onStart: (@Sendable () -> Void)?
    private(set) var calls: [String] = []
    private(set) var settings: [AVCapturePhotoSettings] = []
    private(set) weak var delegate: AVCapturePhotoCaptureDelegate?

    func configure() -> Bool {
        calls.append("configure")
        onConfigure?()
        return configureResult
    }
    func startRunning() {
        calls.append("start")
        isRunning = true
        onStart?()
    }
    func stopRunning() {
        calls.append("stop")
        isRunning = false
    }
    func switchCamera() { calls.append("switch") }
    func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate) {
        calls.append("capture")
        self.settings.append(settings)
        self.delegate = delegate
    }
}
