//
//  MainCoordinator+ModyGroup.swift
//  Main
//
//  Created by 김동준 on 7/6/26.
//

import ModyGroupInterface

@MainActor
extension MainCoordinator: ModyGroupRouter {
    public func route(from route: ModyGroupRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        case .finish:
            navigationController.popToRootViewController(animated: true)
        }
    }
}
