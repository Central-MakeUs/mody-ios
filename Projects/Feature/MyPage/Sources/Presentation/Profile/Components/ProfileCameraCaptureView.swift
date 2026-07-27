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
    private let onComplete: (CameraCaptureResult) -> Void
    private let onCancel: () -> Void

    init(
        source: CameraCaptureSource,
        cameraCaptureBuilder: CameraCaptureBuildable,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.source = source
        self.cameraCaptureBuilder = cameraCaptureBuilder
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    func makeUIViewController(context: Context) -> UIViewController {
        cameraCaptureBuilder.makeCameraViewController(
            source: source,
            isCropEnabled: false,
            onComplete: onComplete,
            onCancel: onCancel
        )
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
}
