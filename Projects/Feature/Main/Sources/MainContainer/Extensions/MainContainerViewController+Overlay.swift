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

        showOverlay(viewController, animated: true)
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            showLoadingOverlay()
        } else {
            dismissOverlay(animated: false)
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
                self?.dismissOverlay(animated: false)
            }
        )
        let hostingController = UIHostingController(rootView: alertView)

        showOverlay(hostingController, animated: false)
    }

    func showOverlay(
        _ overlayViewController: UIViewController,
        animated: Bool
    ) {
        removeCurrentOverlay()

        addChild(overlayViewController)
        overlayViewController.view.alpha = animated ? 0 : 1
        overlayViewController.view.backgroundColor = .clear
        view.addSubview(overlayViewController.view)
        overlayViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        overlayViewController.didMove(toParent: self)
        currentOverlayViewController = overlayViewController

        guard animated else { return }

        UIView.animate(withDuration: 0.2) {
            overlayViewController.view.alpha = 1
        }
    }

    func dismissOverlay(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let overlayViewController = currentOverlayViewController else {
            completion?()
            return
        }

        currentOverlayViewController = nil
        overlayViewController.willMove(toParent: nil)

        let removeOverlay = {
            overlayViewController.view.removeFromSuperview()
            overlayViewController.removeFromParent()
            completion?()
        }

        guard animated else {
            removeOverlay()
            return
        }

        UIView.animate(
            withDuration: 0.2,
            animations: {
                overlayViewController.view.alpha = 0
            },
            completion: { _ in
                removeOverlay()
            }
        )
    }
}

private extension MainContainerViewController {
    func showLoadingOverlay() {
        let loadingView = MLoadingIndicatorView()
            .greedyFrame()
            .background(Color.systemBlack.opacity(0.6))
        let hostingController = UIHostingController(rootView: loadingView)

        showOverlay(hostingController, animated: false)
    }

    func dismissingButton(_ button: MAlertButton?) -> MAlertButton? {
        guard let button else { return nil }

        return MAlertButton(button.title, style: button.style) { [weak self] in
            self?.dismissOverlay(animated: false) {
                button.perform()
            }
        }
    }

    func removeCurrentOverlay() {
        guard let overlayViewController = currentOverlayViewController else { return }

        currentOverlayViewController = nil
        overlayViewController.willMove(toParent: nil)
        overlayViewController.view.removeFromSuperview()
        overlayViewController.removeFromParent()
    }
}
