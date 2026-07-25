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
        let capturedPhotoProcessor = capturedPhotoProcessor

        sessionController.capture { [weak self, capturedPhotoProcessor] data in
            // AVFoundation 콜백 큐에서 파일 저장과 다운샘플링을 끝내고 UI만 main으로 넘깁니다.
            guard self != nil,
                  let data,
                  let capturedPhoto = try? capturedPhotoProcessor.makeCapturedPhoto(
                    data: data,
                    fileName: PhotoFileNameUtil.makeCameraFileName()
                  ) else {
                return
            }

            DispatchQueue.main.async { [weak self, capturedPhotoProcessor] in
                guard let self else {
                    capturedPhotoProcessor.removeCapturedPhoto(capturedPhoto)
                    return
                }
                self.setCapturedPhoto(capturedPhoto)
            }
        }
    }

    func presentPhotoLibrary() {
        guard presentedViewController == nil else { return }
        cancelPhotoLibraryLoad()

        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func setCapturedPhoto(_ capturedPhoto: CameraCapturedPhoto) {
        clearCapturedPhoto(removingFile: true)
        self.capturedPhoto = capturedPhoto
        selectedImageView.image = capturedPhoto.previewImage
        selectedImageView.isHidden = false
        bottomCameraShutterView.isHidden = true
        photoConfirmationContainerView.isHidden = false
        roiOverlayView.isHidden = false
        closeButton.tintColor = .systemWhite
        sessionController.stop()
    }

    func resetCapturedPhoto() {
        cancelPhotoLibraryLoad()
        clearCapturedPhoto(removingFile: true)
        selectedImageView.isHidden = true
        bottomCameraShutterView.isHidden = false
        photoConfirmationContainerView.isHidden = true
        roiOverlayView.isHidden = true
        closeButton.tintColor = .gray10
        sessionController.start()
    }

    func completeCapture() {
        cancelPhotoLibraryLoad()

        guard let result = autoreleasepool(invoking: { () -> CameraCaptureResult? in
            guard let capturedPhoto else { return nil }

            let cropOutput = CameraImageCropper().crop(
                image: capturedPhoto.previewImage,
                selectionFrame: roiOverlayView.selectionFrame,
                containerSize: roiOverlayView.bounds.size
            )
            guard let cropOutput else { return nil }

            let result = CameraCaptureResult(
                originalFile: capturedPhoto.originalFile,
                croppedPreviewImage: cropOutput.croppedImage,
                normalizedSelectionFrame: cropOutput.normalizedSelectionFrame
            )
            clearCapturedPhoto(removingFile: false)
            return result
        }) else {
            return
        }

        onComplete(result)
    }

    @objc func closeTapped() {
        cancelPhotoLibraryLoad()
        sessionController.cancelPendingCapture()
        clearCapturedPhoto(removingFile: true)
        onCancel()
    }

    func removeCapturedPhotoFile() {
        guard let capturedPhoto else { return }
        capturedPhotoProcessor.removeCapturedPhoto(capturedPhoto)
    }

    func clearCapturedPhoto(removingFile: Bool) {
        if removingFile {
            removeCapturedPhotoFile()
        }
        capturedPhoto = nil
        selectedImageView.image = nil
    }

    func cancelPhotoLibraryLoad() {
        photoLibraryLoadProgress?.cancel()
        photoLibraryLoadProgress = nil
        photoLibraryLoadID = nil
    }
}
