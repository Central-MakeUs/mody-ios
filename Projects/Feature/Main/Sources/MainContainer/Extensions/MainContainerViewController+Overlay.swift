//
//  MainContainerViewController+Overlay.swift
//  Main
//
//  Created by 김동준 on 7/5/26
//

import UIKit
import SwiftUI
import SnapKit

extension MainContainerViewController {
    func presentAddGroupAlert() {
        let viewController = UIHostingController(
            rootView: MainAddGroupAlertView(
                onDismiss: { [weak self] in
                    self?.dismissOverlay()
                },
                onParticipateTap: { [weak self] in
                    self?.dismissOverlay {
                        self?.onGroupParticipateTap?()
                    }
                },
                onCreateTap: { [weak self] in
                    self?.dismissOverlay {
                        self?.onGroupCreateTap?()
                    }
                }
            )
        )

        showOverlay(viewController)
    }

    func showOverlay(_ overlayViewController: UIViewController) {
        removeCurrentOverlay()

        addChild(overlayViewController)
        overlayViewController.view.alpha = 0
        overlayViewController.view.backgroundColor = .clear
        view.addSubview(overlayViewController.view)
        overlayViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        overlayViewController.didMove(toParent: self)
        currentOverlayViewController = overlayViewController

        UIView.animate(withDuration: 0.2) {
            overlayViewController.view.alpha = 1
        }
    }

    func dismissOverlay(completion: (() -> Void)? = nil) {
        guard let overlayViewController = currentOverlayViewController else {
            completion?()
            return
        }

        currentOverlayViewController = nil
        overlayViewController.willMove(toParent: nil)

        UIView.animate(
            withDuration: 0.2,
            animations: {
                overlayViewController.view.alpha = 0
            },
            completion: { _ in
                overlayViewController.view.removeFromSuperview()
                overlayViewController.removeFromParent()
                completion?()
            }
        )
    }
}

private extension MainContainerViewController {
    func removeCurrentOverlay() {
        guard let overlayViewController = currentOverlayViewController else { return }

        overlayViewController.willMove(toParent: nil)
        overlayViewController.view.removeFromSuperview()
        overlayViewController.removeFromParent()
        currentOverlayViewController = nil
    }
}
