//
//  MainCoordinator+Notification.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import FeedInterface

@MainActor
extension MainCoordinator {
    func showNotification() {
        let viewController = notificationBuilder.makeNotificationViewController { [weak self] route in
            self?.route(from: route)
        }
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func route(from route: NotificationRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        case let .record(recordType):
            navigationController.popViewController(animated: true)

            guard let transitionCoordinator = navigationController.transitionCoordinator else {
                self.route(from: FeedRoute.routeToRecord(recordType))
                return
            }

            transitionCoordinator.animate(alongsideTransition: nil) { [weak self] context in
                guard !context.isCancelled else { return }
                self?.route(from: FeedRoute.routeToRecord(recordType))
            }
        }
    }
}
