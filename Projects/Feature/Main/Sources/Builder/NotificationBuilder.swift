//
//  NotificationBuilder.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import ComposableArchitecture
import CoreAnalyticsInterface
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
    private let analyticsUseCase: AnalyticsUseCaseProtocol

    init(
        notificationUseCase: NotificationUseCaseProtocol,
        analyticsUseCase: AnalyticsUseCaseProtocol
    ) {
        self.notificationUseCase = notificationUseCase
        self.analyticsUseCase = analyticsUseCase
    }

    func makeNotificationViewController(
        router: @escaping @MainActor (NotificationRoute) -> Void
    ) -> UIViewController {
        let store = Store(
            initialState: NotificationFeature.State()
        ) {
            NotificationFeature(
                notificationUseCase: notificationUseCase,
                analyticsUseCase: analyticsUseCase,
                router: router
            )
        }

        return UIHostingController(rootView: NotificationView(store: store))
    }
}
