//
//  ProfileCameraCaptureView.swift
//  MyPage
//
//  Created by 김동준 on 7/26/26.
//

import CoreCameraInterface
import SwiftUI
import UIKit

struct ProfileCameraCaptureView: UIViewControllerRepresentable {
    private let source: CameraCaptureSource
    private let cameraCaptureBuilder: CameraCaptureBuildable
    private let onEvent: (CameraCaptureEvent) -> Void
    private let onComplete: (CameraCaptureResult) -> Void
    private let onCancel: () -> Void

    init(
        source: CameraCaptureSource,
        cameraCaptureBuilder: CameraCaptureBuildable,
        onEvent: @escaping (CameraCaptureEvent) -> Void,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.source = source
        self.cameraCaptureBuilder = cameraCaptureBuilder
        self.onEvent = onEvent
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    func makeUIViewController(context: Context) -> UIViewController {
        cameraCaptureBuilder.makeCameraViewController(
            source: source,
            isCropEnabled: false,
            cropAspectRatio: nil,
            onEvent: onEvent,
            onComplete: onComplete,
            onCancel: onCancel
        )
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
}
