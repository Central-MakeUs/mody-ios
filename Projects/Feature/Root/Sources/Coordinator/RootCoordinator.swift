//
//  RootCoordinator.swift
//  Root
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import SplashInterface
import SignInInterface
import OnBoardingInterface
import SignUpDoneInterface

public final class RootCoordinator {
    public let navigationController: UINavigationController
    public weak var delegate: RootCoordinatorDelegate?
    
    let splashBuilder: SplashBuildable
    let signInBuilder: SignInBuildable
    let onBoardingBuilder: OnBoardingBuildable
    let signUpDoneBuilder: SignUpDoneBuildable

    public init(
        navigationController: UINavigationController = UINavigationController(), //SwipeBackNavigationController(),
        splashBuilder: SplashBuildable,
        signInBuilder: SignInBuildable,
        onBoardingBuilder: OnBoardingBuildable,
        signUpDoneBuilder: SignUpDoneBuildable,
        delegate: RootCoordinatorDelegate? = nil
    ) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
        self.splashBuilder = splashBuilder
        self.signInBuilder = signInBuilder
        self.onBoardingBuilder = onBoardingBuilder
        self.signUpDoneBuilder = signUpDoneBuilder
        self.delegate = delegate
    }
    
    @MainActor
    public func start() {
        showSplash()
    }
}
