//
//  AppCoordinator+.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Root
import UIKit

extension AppCoordinator {
    @MainActor
    func showRoot(animated: Bool) {
        mainCoordinator = nil

        let coordinator = makeRootCoordinator(self)
        rootCoordinator = coordinator
        setRoot(coordinator.navigationController, animated: animated)
        coordinator.start()
    }
    
    @MainActor
    func showMain(animated: Bool) {
        rootCoordinator = nil

        let coordinator = makeMainCoordinator(self)
        mainCoordinator = coordinator
        setRoot(coordinator.navigationController, animated: animated)
        coordinator.start()
    }

    @MainActor
    func setRoot(_ viewController: UIViewController, animated: Bool) {
        guard animated else {
            window.rootViewController = viewController
            return
        }

        UIView.transition(
            with: window,
            duration: 0.25,
            options: [.transitionCrossDissolve, .allowAnimatedContent],
            animations: { [weak window] in
                window?.rootViewController = viewController
            }
        )
    }
}
