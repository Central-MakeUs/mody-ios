//
//  MainCoordinator+Notification.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import ChallengeInterface
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
        case .feed:
            popNotification { [weak self] in
                self?.mainContainerViewController?.selectTab(.feed)
            }
        case .challenge:
            popNotification { [weak self] in
                self?.challengeInputHandler?.handle(input: .challengeDetailRequested)
                self?.mainContainerViewController?.selectTab(.challenge)
            }
        case let .record(recordType):
            popNotification { [weak self] in
                self?.route(from: FeedRoute.routeToRecord(recordType))
            }
        }
    }

    private func popNotification(completion: @escaping () -> Void) {
        navigationController.popViewController(animated: true)

        guard let transitionCoordinator = navigationController.transitionCoordinator else {
            completion()
            return
        }

        transitionCoordinator.animate(alongsideTransition: nil) { context in
            guard !context.isCancelled else { return }
            completion()
        }
    }
}
