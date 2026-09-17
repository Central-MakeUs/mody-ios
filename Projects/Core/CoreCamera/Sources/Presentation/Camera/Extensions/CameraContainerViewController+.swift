//
//  CameraContainerViewController+.swift
//  CoreCamera
//
//  Created by 김동준 on 7/23/26
//

import CoreCameraInterface
import CoreModyImageInterface
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
        resetRotationState()
        previewView.isHidden = true
        self.capturedPhoto = capturedPhoto
        rotatedPreviewImage = capturedPhoto.previewImage
        selectedImageView.image = rotatedPreviewImage
        selectedImageView.isHidden = false
        rotateLeftButton.isHidden = false
        rotateRightButton.isHidden = false
        bottomCameraShutterView.isHidden = true
        photoConfirmationContainerView.isHidden = false
        roiOverlayView.isHidden = !isCropEnabled
        updateROISelectableFrame(resetSelection: true)
        closeButton.tintColor = .systemWhite
        sessionController.stop()
    }

    func resetCapturedPhoto() {
        cancelPhotoLibraryLoad()
        clearCapturedPhoto(removingFile: true)
        resetRotationState()
        rotatedPreviewImage = nil
        previewView.isHidden = false
        selectedImageView.isHidden = true
        rotateLeftButton.isHidden = true
        rotateRightButton.isHidden = true
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

            let previewImage: UIImage
            let normalizedSelectionFrame: CGRect
            guard let rotatedPreviewImage = self.rotatedPreviewImage else {
                return nil
            }

            if isCropEnabled {
                guard let cropOutput = CameraImageCropper().crop(
                    image: rotatedPreviewImage,
                    selectionFrame: roiOverlayView.selectionFrame,
                    containerSize: roiOverlayView.bounds.size,
                    displayMode: .aspectFit
                ) else {
                    return nil
                }
                previewImage = cropOutput.croppedImage
                normalizedSelectionFrame = cropOutput.normalizedSelectionFrame
            } else {
                previewImage = rotatedPreviewImage
                normalizedSelectionFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
            }

            let originalFile: TemporaryImageFile
            if imageRotation == .zero {
                originalFile = capturedPhoto.originalFile
            } else {
                guard let rotatedFile = try? capturedPhotoProcessor.makeRotatedFile(
                    from: capturedPhoto,
                    rotation: imageRotation
                ) else {
                    return nil
                }
                originalFile = rotatedFile
            }

            let result = CameraCaptureResult(
                originalFile: originalFile,
                croppedPreviewImage: previewImage,
                normalizedSelectionFrame: normalizedSelectionFrame
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

    func updateROISelectableFrame(resetSelection: Bool = false) {
        guard isCropEnabled else { return }

        let displayedFrame = rotatedPreviewImage.flatMap {
            CameraDisplayedImageLayout.make(
                imageSize: $0.size,
                containerSize: roiOverlayView.bounds.size,
                displayMode: .aspectFit
            )?.displayedImageFrame
        } ?? roiOverlayView.bounds

        if resetSelection {
            roiOverlayView.resetSelection(in: displayedFrame)
        } else {
            roiOverlayView.updateSelectableFrame(displayedFrame)
        }
    }

    func rotateCapturedPhoto(clockwiseDegrees: Int) {
        guard let capturedPhoto, !isRotatingPhoto else { return }

        isRotatingPhoto = true
        rotateLeftButton.isUserInteractionEnabled = false
        rotateRightButton.isUserInteractionEnabled = false
        imageRotation = imageRotation.adding(clockwise: clockwiseDegrees)
        roiOverlayView.isHidden = true

        let radians = CGFloat(clockwiseDegrees) * .pi / 180
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: { [weak self] in
                self?.selectedImageView.transform = CGAffineTransform(rotationAngle: radians)
            },
            completion: { [weak self] _ in
                guard let self else { return }

                let rotatedImage = CameraImageRotator().rotate(
                    capturedPhoto.previewImage,
                    by: self.imageRotation
                )
                UIView.performWithoutAnimation {
                    self.selectedImageView.transform = .identity
                    self.rotatedPreviewImage = rotatedImage
                    self.selectedImageView.image = rotatedImage
                }
                self.updateROISelectableFrame(resetSelection: true)
                self.roiOverlayView.isHidden = !self.isCropEnabled
                self.rotateLeftButton.isUserInteractionEnabled = true
                self.rotateRightButton.isUserInteractionEnabled = true
                self.isRotatingPhoto = false
            }
        )
    }

    func resetRotationState() {
        imageRotation = .zero
        isRotatingPhoto = false
        rotateLeftButton.isUserInteractionEnabled = true
        rotateRightButton.isUserInteractionEnabled = true
        selectedImageView.transform = .identity
    }

    @objc func rotateLeftTapped() {
        rotateCapturedPhoto(clockwiseDegrees: -90)
    }

    @objc func rotateRightTapped() {
        rotateCapturedPhoto(clockwiseDegrees: 90)
    }
}
