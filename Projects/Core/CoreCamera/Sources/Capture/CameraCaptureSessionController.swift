//
//  CameraCaptureSessionController.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import AVFoundation
import Foundation

/// 세션 구성과 실행은 전용 직렬 큐에서 처리하며, 촬영 완료 콜백은 main queue를 보장하지 않습니다.
final class CameraCaptureSessionController: NSObject, @unchecked Sendable {
    private struct PendingCapture {
        let uniqueID: Int64
        let completion: (Data?) -> Void
    }

    let session = AVCaptureSession()

    private let permissionService = CameraPermissionService()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.mody.core-camera.capture-session")
    private let captureCompletionLock = NSLock()

    private var videoInput: AVCaptureDeviceInput?
    private var pendingCapture: PendingCapture?
    private var isConfigured = false
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
                configureSessionIfNeeded()
                guard isConfigured, !session.isRunning else { return }
                session.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, session.isRunning else { return }
            session.stopRunning()
        }
    }

    func capture(completion: @escaping (Data?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self, isConfigured else {
                completion(nil)
                return
            }

            let settings: AVCapturePhotoSettings
            if photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
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
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func cancelPendingCapture() {
        sessionQueue.async { [weak self] in
            self?.clearPendingCapture()
        }
    }

    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self,
                  let currentInput = videoInput else { return }

            let nextPosition: AVCaptureDevice.Position =
                currentInput.device.position == .back ? .front : .back
            guard let device = makeCamera(position: nextPosition),
                  let nextInput = try? AVCaptureDeviceInput(device: device) else { return }

            session.beginConfiguration()
            session.removeInput(currentInput)

            if session.canAddInput(nextInput) {
                session.addInput(nextInput)
                videoInput = nextInput
            } else {
                session.addInput(currentInput)
            }

            session.commitConfiguration()
        }
    }
}

private extension CameraCaptureSessionController {
    func configureSessionIfNeeded() {
        guard !isConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .photo
        defer { session.commitConfiguration() }

        guard let device = makeCamera(position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(photoOutput) else { return }

        session.addInput(input)
        session.addOutput(photoOutput)
        videoInput = input
        isConfigured = true
    }

    func makeCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: position
        )
    }

    func storeCaptureCompletionIfPossible(
        _ completion: @escaping (Data?) -> Void,
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

    func takeCaptureCompletion(uniqueID: Int64) -> ((Data?) -> Void)? {
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
        guard let completion = takeCaptureCompletion(
            uniqueID: photo.resolvedSettings.uniqueID
        ) else {
            return
        }

        let data = autoreleasepool {
            error == nil ? photo.fileDataRepresentation() : nil
        }
        completion(data)
    }
}
