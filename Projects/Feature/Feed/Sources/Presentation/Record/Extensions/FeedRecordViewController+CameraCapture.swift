//
//  FeedRecordViewController+CameraCapture.swift
//  Feed
//
//  Created by 김동준 on 7/20/26.
//

import CoreCameraInterface
import UIKit

extension FeedRecordViewController {
    func presentCameraCapture(source: CameraCaptureSource) {
        guard cameraContainerViewController == nil else { return }

        let cameraContainerViewController = cameraCaptureBuilder.makeCameraViewController(
            source: source,
            onComplete: { [weak self] result in
                self?.dismissCameraCapture {
                    self?.reactor?.action.onNext(.didCompletePhotoCapture(result))
                }
            },
            onCancel: { [weak self] in
                self?.dismissCameraCapture {
                    self?.reactor?.action.onNext(.didDismissPhotoPresentation)
                }
            }
        )
        cameraContainerViewController.modalPresentationStyle = .fullScreen
        self.cameraContainerViewController = cameraContainerViewController

        if let photoSourceSheetViewController {
            self.photoSourceSheetViewController = nil
            photoSourceSheetViewController.dismiss(animated: true) { [weak self] in
                self?.present(cameraContainerViewController, animated: true)
            }
        } else {
            present(cameraContainerViewController, animated: true)
        }
    }
}

private extension FeedRecordViewController {
    func dismissCameraCapture(completion: @escaping () -> Void = {}) {
        guard let cameraContainerViewController else {
            completion()
            return
        }

        cameraContainerViewController.dismiss(animated: true) { [weak self] in
            self?.cameraContainerViewController = nil
            completion()
        }
    }
}
