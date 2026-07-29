//
//  AppCoordinator+RootCoordinatorDelegate.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Root

@MainActor
extension AppCoordinator: RootCoordinatorDelegate {
    func didFinishAuthentication(_ coordinator: RootCoordinator) {
        showMain(animated: true)
    }
}
