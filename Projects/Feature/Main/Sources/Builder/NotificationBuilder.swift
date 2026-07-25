//
//  NotificationBuilder.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import ComposableArchitecture
import CoreNotificationInterface
import SwiftUI
import UIKit

@MainActor
protocol NotificationBuildable {
    func makeNotificationViewController(
        router: @escaping @MainActor (NotificationRoute) -> Void
    ) -> UIViewController
}

struct NotificationBuilder: NotificationBuildable {
    private let notificationUseCase: NotificationUseCaseProtocol

    init(notificationUseCase: NotificationUseCaseProtocol) {
        self.notificationUseCase = notificationUseCase
    }

    func makeNotificationViewController(
        router: @escaping @MainActor (NotificationRoute) -> Void
    ) -> UIViewController {
        let store = Store(
            initialState: NotificationFeature.State()
        ) {
            NotificationFeature(
                notificationUseCase: notificationUseCase,
                router: router
            )
        }

        return UIHostingController(rootView: NotificationView(store: store))
    }
}
