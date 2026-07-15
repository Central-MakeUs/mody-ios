//
//  MainCoordinator+FeedRecord.swift
//  Main
//
//  Created by 김동준 on 7/12/26
//

import FeedInterface

extension MainCoordinator: FeedRecordRouter {
    public func route(from route: FeedRecordRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        }
    }
}
