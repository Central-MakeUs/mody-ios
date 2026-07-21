//
//  CameraCaptureSessionController.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import AVFoundation
import UIKit

final class CameraCaptureSessionController: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()

    private let permissionService = CameraPermissionService()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.mody.core-camera.capture-session")

    private var videoInput: AVCaptureDeviceInput?
    private var captureCompletion: ((UIImage?) -> Void)?
    private var isConfigured = false
}

extension CameraCaptureSessionController {
    func start() {
        Task { [weak self] in
            guard let self else { return }

            let isGranted: Bool
            if permissionService.isCameraPermissionNotDetermined() {
                isGranted = await permissionService.requestCameraPermission()
            } else {
                isGranted = permissionService.isCameraPermissionGranted()
            }

            guard isGranted else { return }

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

    func capture(completion: @escaping (UIImage?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self, isConfigured else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            captureCompletion = completion
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
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
}

extension CameraCaptureSessionController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image = error == nil
            ? photo.fileDataRepresentation().flatMap(UIImage.init(data:))
            : nil
        let completion = captureCompletion
        captureCompletion = nil

        DispatchQueue.main.async {
            completion?(image)
        }
    }
}
