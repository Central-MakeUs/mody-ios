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
        guard cameraCaptureViewController == nil else { return }

        let viewController = cameraCaptureBuilder.makeCameraViewController(
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
        viewController.modalPresentationStyle = .fullScreen
        cameraCaptureViewController = viewController

        if let photoSourceSheetViewController {
            self.photoSourceSheetViewController = nil
            photoSourceSheetViewController.dismiss(animated: true) { [weak self] in
                self?.present(viewController, animated: true)
            }
        } else {
            present(viewController, animated: true)
        }
    }
}

private extension FeedRecordViewController {
    func dismissCameraCapture(completion: @escaping () -> Void = {}) {
        guard let cameraCaptureViewController else {
            completion()
            return
        }

        cameraCaptureViewController.dismiss(animated: true) { [weak self] in
            self?.cameraCaptureViewController = nil
            completion()
        }
    }
}
