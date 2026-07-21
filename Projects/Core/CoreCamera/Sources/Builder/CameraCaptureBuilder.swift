//
//  CameraCaptureBuilder.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import CoreCameraInterface
import UIKit

public struct CameraCaptureBuilder: CameraCaptureBuildable {
    public init() {}

    @MainActor
    public func makeCameraViewController(
        source: CameraCaptureSource,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) -> UIViewController {
        CameraCaptureViewController(
            initialSource: source,
            onComplete: onComplete,
            onCancel: onCancel
        )
    }
}
