//
//  CameraContainerViewController+.swift
//  CoreCamera
//
//  Created by 김동준 on 7/23/26
//

import CoreCameraInterface
import DesignSystem
import PhotosUI
import UIKit

extension CameraContainerViewController {
    func capturePhoto() {
        sessionController.capture { [weak self] image in
            guard let image else { return }
            self?.setCapturedPhoto(
                image,
                originalFileName: PhotoFileNameUtil.makeCameraFileName()
            )
        }
    }

    func presentPhotoLibrary() {
        guard presentedViewController == nil else { return }

        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func setCapturedPhoto(
        _ image: UIImage,
        originalFileName: String
    ) {
        capturedPhoto = CapturedPhoto(
            image: image,
            originalFileName: originalFileName
        )
        selectedImageView.image = image
        selectedImageView.isHidden = false
        bottomCameraShutterView.isHidden = true
        photoConfirmationContainerView.isHidden = false
        roiOverlayView.isHidden = false
        closeButton.tintColor = .systemWhite
        sessionController.stop()
    }

    func resetCapturedPhoto() {
        capturedPhoto = nil
        selectedImageView.image = nil
        selectedImageView.isHidden = true
        bottomCameraShutterView.isHidden = false
        photoConfirmationContainerView.isHidden = true
        roiOverlayView.isHidden = true
        closeButton.tintColor = .gray10
        sessionController.start()
    }

    func completeCapture() {
        guard let capturedPhoto else { return }

        let selectionFrame = roiOverlayView.selectionFrame
        let selectionContainerSize = roiOverlayView.bounds.size
        let cropOutput = CameraImageCropper().crop(
            image: capturedPhoto.image,
            selectionFrame: selectionFrame,
            containerSize: selectionContainerSize
        )
        guard let cropOutput else { return }

        printSelectionCoordinates(
            selectionFrame: selectionFrame,
            cropOutput: cropOutput
        )

        onComplete(
            CameraCaptureResult(
                image: capturedPhoto.image,
                croppedImage: cropOutput.croppedImage,
                normalizedSelectionFrame: cropOutput.normalizedSelectionFrame,
                originalFileName: capturedPhoto.originalFileName
            )
        )
    }

    func printSelectionCoordinates(
        selectionFrame: CGRect,
        cropOutput: CameraImageCropOutput
    ) {
        print(
            """
            [CoreCamera][Upload]
            관심 영역 좌표 (화면, 좌상단 원점): \(selectionFrame)
            원본 사진 좌표 (좌상단 원점): \(cropOutput.originalImageBounds)
            관심 영역 좌표 (원본 사진 기준, 좌상단 원점): \(cropOutput.selectionFrameInOriginalImage)
            관심 영역 정규화 좌표 (원본 사진 기준, 0...1): \(cropOutput.normalizedSelectionFrame)
            """
        )
    }

    @objc func closeTapped() {
        onCancel()
    }
}
