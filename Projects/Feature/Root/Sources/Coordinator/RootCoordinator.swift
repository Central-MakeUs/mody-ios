//
//  RootCoordinator.swift
//  Root
//
//  Created by 김동준 on 6/25/26
//

import UIKit
import Base
import SplashInterface
import SignInInterface
import OnBoardingInterface
import ModyGroupInterface

public final class RootCoordinator {
    public let navigationController: UINavigationController
    public weak var delegate: RootCoordinatorDelegate?
    
    let splashBuilder: SplashBuildable
    let signInBuilder: SignInBuildable
    let onBoardingBuilder: OnBoardingBuildable
    let modyGroupBuilder: ModyGroupBuildable

    public init(
        navigationController: UINavigationController = SwipeBackNavigationController(),
        splashBuilder: SplashBuildable,
        signInBuilder: SignInBuildable,
        onBoardingBuilder: OnBoardingBuildable,
        modyGroupBuilder: ModyGroupBuildable,
        delegate: RootCoordinatorDelegate? = nil
    ) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
        self.splashBuilder = splashBuilder
        self.signInBuilder = signInBuilder
        self.onBoardingBuilder = onBoardingBuilder
        self.modyGroupBuilder = modyGroupBuilder
        self.delegate = delegate
    }
    
    @MainActor
    public func start() {
        showSplash()
    }

    @MainActor
    public func startSignIn() {
        showSignIn()
    }
}
