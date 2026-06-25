//
//  RootCoordinator.swift
//  Root
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import SplashInterface

public final class RootCoordinator {
    public let navigationController: UINavigationController
    public weak var delegate: RootCoordinatorDelegate?

    private let splashBuilder: SplashBuildable

    public init(
        navigationController: UINavigationController = UINavigationController(), //SwipeBackNavigationController(),
        splashBuilder: SplashBuildable,
        delegate: RootCoordinatorDelegate? = nil
    ) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
        self.splashBuilder = splashBuilder
        self.delegate = delegate
    }

    @MainActor
    public func start() {
        showSplash()
    }

    @MainActor
    private func showSplash() {
        let viewController = splashBuilder.makeSplashViewController(router: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
