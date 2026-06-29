//
//  SwipeBackNavigationController.swift
//  Base
//
//  Created by 김동준 on 6/29/26.
//

import UIKit

public final class SwipeBackNavigationController: UINavigationController {
    private weak var swipingViewController: UIViewController?

    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
}

private extension SwipeBackNavigationController {
    func finishSwipeBack(didShow shownViewController: UIViewController) {
        guard let swipingViewController else { return }
        defer { self.swipingViewController = nil }

        if shownViewController === swipingViewController {
            (swipingViewController as? SwipeBackEventReceivable)?.swipeBackDidCancel()
            return
        }

        if !viewControllers.contains(where: { $0 === swipingViewController }) {
            (swipingViewController as? SwipeBackEventReceivable)?.swipeBackDidComplete()
        }
    }
}

extension SwipeBackNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === interactivePopGestureRecognizer else { return true }
        guard viewControllers.count > 1 else { return false }
        guard transitionCoordinator == nil else { return false }
        guard topViewController?.isSwipeBackEnabled == true else { return false }

        swipingViewController = topViewController
        return true
    }
}

extension SwipeBackNavigationController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        finishSwipeBack(didShow: viewController)
    }
}
