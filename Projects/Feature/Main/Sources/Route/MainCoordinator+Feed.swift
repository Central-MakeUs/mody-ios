//
//  MainCoordinator+Feed.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import FeedInterface

extension MainCoordinator: FeedRouter {
    public func route(from route: FeedRoute) {
        switch route {
        case .temp:
            // TODO: 추후 구현
            break
        }
    }
}
