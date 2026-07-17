//
//  FeedRecordViewController+PhotoSourceSheet.swift
//  Feed
//
//  Created by 김동준 on 7/15/26.
//

import UIKit
import SwiftUI
import DesignSystem

extension FeedRecordViewController {
    func setPhotoSourceSheetPresented(_ isPresented: Bool) {
        if isPresented {
            presentPhotoSourceSheet()
        } else {
            dismissPhotoSourceSheet()
        }
    }
}

private extension FeedRecordViewController {
    func presentPhotoSourceSheet() {
        guard photoSourceSheetViewController == nil,
              presentedViewController == nil else { return }

        let viewController = UIHostingController(
            rootView: FeedRecordPhotoSourceSheetView(
                onCameraTap: { [weak self] in
                    self?.reactor?.action.onNext(.didTapCamera)
                },
                onGalleryTap: { [weak self] in
                    self?.reactor?.action.onNext(.didTapGallery)
                }
            )
        )
        viewController.view.backgroundColor = .systemWhite
        viewController.modalPresentationStyle = .pageSheet

        if let sheetPresentationController = viewController.sheetPresentationController {
            let identifier = UISheetPresentationController.Detent.Identifier("photoSource")
            let totalHeight: CGFloat = 200
            let bottomInset = view.window?.safeAreaInsets.bottom ?? view.safeAreaInsets.bottom

            sheetPresentationController.detents = [
                .custom(identifier: identifier) { _ in
                    max(0, totalHeight - bottomInset)
                }
            ]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.preferredCornerRadius = 36
            sheetPresentationController.delegate = self
        }

        photoSourceSheetViewController = viewController
        present(viewController, animated: true)
    }

    func dismissPhotoSourceSheet() {
        guard let photoSourceSheetViewController else { return }

        photoSourceSheetViewController.dismiss(animated: true) { [weak self] in
            self?.photoSourceSheetViewController = nil
        }
    }
}

extension FeedRecordViewController: UISheetPresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        photoSourceSheetViewController = nil
        reactor?.action.onNext(.didDismissPhotoSourceSheet)
    }
}
