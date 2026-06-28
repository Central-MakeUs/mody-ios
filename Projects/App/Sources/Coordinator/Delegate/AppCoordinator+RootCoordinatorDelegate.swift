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
        // TODO: Main 전환
        print("Main 전환 감지")
    }
}
