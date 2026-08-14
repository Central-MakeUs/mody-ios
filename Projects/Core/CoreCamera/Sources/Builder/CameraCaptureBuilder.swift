//
//  CameraCaptureBuilder.swift
//  CoreCamera
//
//  Created by 김동준 on 7/20/26.
//

import CoreCameraInterface
import CoreModyImageInterface
import UIKit

public struct CameraCaptureBuilder: CameraCaptureBuildable {
    private let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol

    public init(temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol) {
        self.temporaryImageFileUseCase = temporaryImageFileUseCase
    }

    @MainActor
    public func makeCameraViewController(
        source: CameraCaptureSource,
        isCropEnabled: Bool,
        cropSize: CGSize?,
        onComplete: @escaping (CameraCaptureResult) -> Void,
        onCancel: @escaping () -> Void
    ) -> UIViewController {
        let capturedPhotoProcessor = CameraCapturedPhotoProcessor(
            temporaryImageFileUseCase: temporaryImageFileUseCase,
            previewMaxPixelSize: CameraContainerViewController.previewMaxPixelSize
        )

        return CameraContainerViewController(
            initialSource: source,
            isCropEnabled: isCropEnabled,
            cropSize: cropSize,
            capturedPhotoProcessor: capturedPhotoProcessor,
            onComplete: onComplete,
            onCancel: onCancel
        )
    }
}
