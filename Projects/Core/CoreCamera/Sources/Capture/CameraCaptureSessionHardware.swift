//  CameraCaptureSessionHardware.swift
//  CoreCamera
//
//  Created by 김동준 on 10/9/26.
//

import AVFoundation

/// AVFoundation 장치 접근 경계. 호출은 controller의 직렬 큐에서 실행합니다.
protocol CameraCaptureSessionHardware: AnyObject {
    var session: AVCaptureSession { get }
    var isRunning: Bool { get }
    var availablePhotoCodecTypes: [AVVideoCodecType] { get }
    func configure() -> Bool
    func startRunning()
    func stopRunning()
    func switchCamera()
    func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate)
}

final class AVCameraCaptureSessionHardware: CameraCaptureSessionHardware {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoInput: AVCaptureDeviceInput?

    var isRunning: Bool { session.isRunning }
    var availablePhotoCodecTypes: [AVVideoCodecType] { photoOutput.availablePhotoCodecTypes }

    func configure() -> Bool {
        session.beginConfiguration()
        session.sessionPreset = .photo
        defer { session.commitConfiguration() }

        guard let input = makeInput(position: .back),
            session.canAddInput(input),
            session.canAddOutput(photoOutput)
        else { return false }
        session.addInput(input)
        session.addOutput(photoOutput)
        videoInput = input
        return true
    }

    func startRunning() { session.startRunning() }
    func stopRunning() { session.stopRunning() }

    func switchCamera() {
        guard let currentInput = videoInput else { return }
        let nextPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
        guard let nextInput = makeInput(position: nextPosition) else { return }
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

    func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate) {
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }

    private func makeInput(position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            return nil
        }
        return try? AVCaptureDeviceInput(device: device)
    }
}
