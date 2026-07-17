//
//  MainContainerViewController+Overlay.swift
//  Main
//
//  Created by 김동준 on 7/5/26
//

import DesignSystem
import SnapKit
import SwiftUI
import UIKit

extension MainContainerViewController {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            showLoadingOverlay()
        } else {
            hideOverlay()
        }
    }

    func showAlert(configuration: MainAlertConfiguration) {
        let alertView = MAlertView(
            title: configuration.title,
            contents: configuration.contents,
            leadingButton: dismissingButton(configuration.leadingButton),
            trailingButton: dismissingButton(configuration.trailingButton),
            dismissOnBackgroundTap: configuration.dismissOnBackgroundTap,
            onDismiss: { [weak self] in
                self?.hideOverlay()
            }
        )
        let hostingController = UIHostingController(rootView: alertView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.accessibilityViewIsModal = true

        showOverlay(
            hostingController.view,
            viewController: hostingController
        )
    }

    func showOverlay(
        _ overlayView: UIView,
        viewController: UIViewController? = nil
    ) {
        hideOverlay()

        if let viewController {
            addChild(viewController)
        }

        view.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        viewController?.didMove(toParent: self)
        currentOverlayView = overlayView
        currentOverlayViewController = viewController
    }

    func hideOverlay() {
        currentOverlayViewController?.willMove(toParent: nil)
        currentOverlayView?.removeFromSuperview()
        currentOverlayViewController?.removeFromParent()
        currentOverlayView = nil
        currentOverlayViewController = nil
    }
}

private extension MainContainerViewController {
    func showLoadingOverlay() {
        let loadingView = MLoadingIndicatorView()
            .greedyFrame()
            .background(Color.systemBlack.opacity(0.6))
        let hostingController = UIHostingController(rootView: loadingView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.accessibilityViewIsModal = true

        showOverlay(
            hostingController.view,
            viewController: hostingController
        )
    }

    func dismissingButton(_ button: MAlertButton?) -> MAlertButton? {
        guard let button else { return nil }

        return MAlertButton(button.title, style: button.style) { [weak self] in
            self?.hideOverlay()
            button.perform()
        }
    }
}
