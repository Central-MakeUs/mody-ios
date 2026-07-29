//
//  MainCoordinator+ModyGroup.swift
//  Main
//
//  Created by 김동준 on 7/6/26.
//

import ModyGroupInterface
import FeedInterface

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

extension MainCoordinator: ModyGroupOutputHandler {
    public func handle(output: ModyGroupOutput) {
        switch output {
        case .groupUpdated:
            feedInputHandler?.handle(input: .refreshGroups)
        }
    }
}
