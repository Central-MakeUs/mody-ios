//
//  CameraCaptureBuildable.swift
//  CoreCameraInterface
//
//  Created by 김동준 on 7/20/26.
//

import UIKit

public protocol CameraCaptureBuildable {
    @MainActor
    func makeCameraViewController(
        source: CameraCaptureSource,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) -> UIViewController
}
