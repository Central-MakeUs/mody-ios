//
//  AppCoordinator+MainCoordinatorDelegate.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import MainInterface

extension AppCoordinator: MainCoordinatorDelegate {
    @MainActor
    func didRequestLogout() {
        showSignIn(animated: true)
    }
}
