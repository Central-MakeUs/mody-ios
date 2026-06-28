//
//  RootCoordinator+.swift
//  Root
//
//  Created by 김동준 on 6/26/26
//

import UIKit
import SplashInterface
import SignInInterface
import OnBoardingInterface
import SignUpDoneInterface

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
    
    func showOnBoarding() {
        let viewController = onBoardingBuilder.makeOnBoardingViewController(router: self)
        setRoot(viewController, animated: false)
    }
    
    func showSignUpDone() {
        let viewController = signUpDoneBuilder.makeSignUpDoneViewController(router: self)
        setRoot(viewController, animated: false)
    }
}
