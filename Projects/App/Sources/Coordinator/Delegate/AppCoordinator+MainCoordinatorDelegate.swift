//
//  AppCoordinator+MainCoordinatorDelegate.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Main

extension AppCoordinator: MainCoordinatorDelegate {
    @MainActor
    func didRequestLogout(_ coordinator: MainCoordinator) {
        showSignIn(animated: true)
    }
}
