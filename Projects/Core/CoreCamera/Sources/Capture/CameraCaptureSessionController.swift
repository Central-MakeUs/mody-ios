//
//  CameraCaptureSessionController.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import AVFoundation
import Foundation
import CoreCameraInterface

/// 세션 구성과 실행은 전용 직렬 큐에서 처리하며, 촬영 완료 콜백은 main queue를 보장하지 않습니다.
final class CameraCaptureSessionController: NSObject, @unchecked Sendable {
    private struct PendingCapture {
        let uniqueID: Int64
        let completion: @Sendable (Data?) -> Void
    }

    var session: AVCaptureSession { hardware.session }

    private let permissionService: CameraPermissionInterface
    private let hardware: CameraCaptureSessionHardware
    private let sessionQueue: DispatchQueue
    private let captureCompletionLock = NSLock()

    private var pendingCapture: PendingCapture?
    private var isConfigured = false

    init(
        permissionService: CameraPermissionInterface = CameraPermissionService(),
        hardware: CameraCaptureSessionHardware = AVCameraCaptureSessionHardware(),
        sessionQueue: DispatchQueue = DispatchQueue(label: "com.mody.core-camera.capture-session")
    ) {
        self.permissionService = permissionService
        self.hardware = hardware
        self.sessionQueue = sessionQueue
        super.init()
    }
}

extension CameraCaptureSessionController {
    func start() {
        let permissionService = permissionService
        Task { [weak self, permissionService] in
            let isGranted: Bool
            if permissionService.isCameraPermissionNotDetermined() {
                isGranted = await permissionService.requestCameraPermission()
            } else {
                isGranted = permissionService.isCameraPermissionGranted()
            }

            guard isGranted, let self else { return }

            sessionQueue.async { [weak self] in
                guard let self else { return }
                if !isConfigured { isConfigured = hardware.configure() }
                guard isConfigured, !hardware.isRunning else { return }
                hardware.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, hardware.isRunning else { return }
            hardware.stopRunning()
        }
    }

    func capture(completion: @escaping @Sendable (Data?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self, isConfigured else {
                completion(nil)
                return
            }

            let settings: AVCapturePhotoSettings
            if hardware.availablePhotoCodecTypes.contains(.jpeg) {
                settings = AVCapturePhotoSettings(
                    format: [AVVideoCodecKey: AVVideoCodecType.jpeg]
                )
            } else {
                settings = AVCapturePhotoSettings()
            }
            guard storeCaptureCompletionIfPossible(
                completion,
                uniqueID: settings.uniqueID
            ) else {
                completion(nil)
                return
            }
            hardware.capturePhoto(with: settings, delegate: self)
        }
    }

    func cancelPendingCapture() {
        sessionQueue.async { [weak self] in
            self?.clearPendingCapture()
        }
    }

    func switchCamera() {
        sessionQueue.async { [weak self] in
            self?.hardware.switchCamera()
        }
    }

    func finishCapture(uniqueID: Int64, error: Error?, data: () -> Data?) {
        guard let completion = takeCaptureCompletion(uniqueID: uniqueID) else { return }
        completion(error == nil ? autoreleasepool(invoking: data) : nil)
    }
}

private extension CameraCaptureSessionController {
    func storeCaptureCompletionIfPossible(
        _ completion: @escaping @Sendable (Data?) -> Void,
        uniqueID: Int64
    ) -> Bool {
        captureCompletionLock.lock()
        defer { captureCompletionLock.unlock() }

        guard pendingCapture == nil else { return false }
        pendingCapture = PendingCapture(
            uniqueID: uniqueID,
            completion: completion
        )
        return true
    }

    func takeCaptureCompletion(uniqueID: Int64) -> (@Sendable (Data?) -> Void)? {
        captureCompletionLock.lock()
        defer { captureCompletionLock.unlock() }

        guard pendingCapture?.uniqueID == uniqueID else { return nil }
        defer { pendingCapture = nil }
        return pendingCapture?.completion
    }

    func clearPendingCapture() {
        captureCompletionLock.lock()
        defer { captureCompletionLock.unlock() }
        pendingCapture = nil
    }
}

extension CameraCaptureSessionController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        finishCapture(uniqueID: photo.resolvedSettings.uniqueID, error: error) {
            photo.fileDataRepresentation()
        }
    }
}
