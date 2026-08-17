//
//  ChallengeWeeklyCameraCaptureView.swift
//  Challenge
//
//  Created by 김동준 on 8/14/26.
//

import CoreCameraInterface
import SwiftUI
import UIKit

struct ChallengeWeeklyCameraCaptureView: UIViewControllerRepresentable {
    private let source: CameraCaptureSource
    private let cropAspectRatio: CGSize
    private let cameraCaptureBuilder: CameraCaptureBuildable
    private let onComplete: (CameraCaptureResult) -> Void
    private let onCancel: () -> Void

    init(
        source: CameraCaptureSource,
        cropAspectRatio: CGSize,
        cameraCaptureBuilder: CameraCaptureBuildable,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.source = source
        self.cropAspectRatio = cropAspectRatio
        self.cameraCaptureBuilder = cameraCaptureBuilder
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    func makeUIViewController(context: Context) -> UIViewController {
        cameraCaptureBuilder.makeCameraViewController(
            source: source,
            isCropEnabled: true,
            cropAspectRatio: cropAspectRatio,
            onComplete: onComplete,
            onCancel: onCancel
        )
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
}
