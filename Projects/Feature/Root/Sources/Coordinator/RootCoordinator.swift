//
//  RootCoordinator.swift
//  Root
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import SplashInterface
import SignInInterface

public final class RootCoordinator {
    public let navigationController: UINavigationController
    public weak var delegate: RootCoordinatorDelegate?
    
    private let splashBuilder: SplashBuildable
    private let signInBuilder: SignInBuildable
    
    public init(
        navigationController: UINavigationController = UINavigationController(), //SwipeBackNavigationController(),
        splashBuilder: SplashBuildable,
        signInBuilder: SignInBuildable,
        delegate: RootCoordinatorDelegate? = nil
    ) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
        self.splashBuilder = splashBuilder
        self.signInBuilder = signInBuilder
        self.delegate = delegate
    }
    
    @MainActor
    public func start() {
        showSplash()
    }
}

@MainActor
extension RootCoordinator {
    func setRoot(_ viewController: UIViewController, animated: Bool) {
        navigationController.setViewControllers([viewController], animated: animated)
    }
    
    func showSplash() {
        let viewController = splashBuilder.makeSplashViewController(router: self)
        setRoot(viewController, animated: false)
    }
    
    func showSignIn() {
        let viewController = signInBuilder.makeSignInViewController(router: self)
        setRoot(viewController, animated: false)
    }
}
