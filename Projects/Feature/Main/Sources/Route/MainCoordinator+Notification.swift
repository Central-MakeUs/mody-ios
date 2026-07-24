//
//  MainCoordinator+Notification.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import ComposableArchitecture
import SwiftUI

@MainActor
extension MainCoordinator {
    func showNotification() {
        let viewController = makeNotificationViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func route(from route: NotificationRoute) {
        switch route {
        case .back:
            navigationController.popViewController(animated: true)
        }
    }
}

@MainActor
extension MainCoordinator {
    private func makeNotificationViewController() -> UIViewController {
        let store: StoreOf<NotificationFeature> = .init(
            initialState: NotificationFeature.State()
        ) {
            NotificationFeature(
                notificationUseCase: notificationUseCase,
                router: { [weak self] route in
                    self?.route(from: route)
                }
            )
        }
        let view = NotificationView(store: store)

        return UIHostingController(rootView: view)
    }
}
