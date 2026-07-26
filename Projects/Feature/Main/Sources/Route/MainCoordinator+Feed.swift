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
        case .addGroup:
            mainContainerViewController?.presentAddGroupAlert()
        case .routeToRecord(let recordType):
            let viewController = feedBuilder.makeFeedRecordViewController(
                router: self,
                recordType: recordType,
                outputHandler: self
            )
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
