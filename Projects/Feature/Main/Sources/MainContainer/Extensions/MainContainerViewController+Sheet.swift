//
//  MainContainerViewController+Sheet.swift
//  Main
//
//  Created by 김동준 on 7/6/26.
//

import SwiftUI

extension MainContainerViewController {
    func presentGroupMenuSheet() {
        let viewController = UIHostingController(
            rootView: MainGroupSelectSheetView(
                onParticipateTap: { [weak self] in
                    self?.dismiss(animated: true) {
                        self?.onSheetGroupParticipateTap?()
                    }
                },
                onCreateTap: { [weak self] in
                    self?.dismiss(animated: true) {
                        self?.onSheetGroupCreateTap?()
                    }
                }
            )
        )
        viewController.view.backgroundColor = .systemWhite
        viewController.modalPresentationStyle = .pageSheet

        if let sheetPresentationController = viewController.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
        }

        present(viewController, animated: true)
    }
}
