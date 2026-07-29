//
//  AppAssembly+CoreNotification.swift
//  Mody
//
//  Created by 김동준 on 7/18/26.
//

import CoreKeyChainStorage
import CoreNetworkInterface
import CoreNotification
import CoreNotificationInterface
import Swinject

extension AppAssembly {
    func assembleCoreNotification(in container: Container) {
        container.register(NotificationService.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return NotificationService(network: network)
        }

        container.register(NotificationRepositoryProtocol.self) { resolver in
            let notificationService: NotificationService = resolver.resolve()

            return NotificationRepository(
                notificationService: notificationService,
                keyChainStorage: CoreKeyChainStorage()
            )
        }

        container.register(NotificationUseCaseProtocol.self) { resolver in
            let notificationRepository: NotificationRepositoryProtocol = resolver.resolve()

            return NotificationUseCase(notificationRepository: notificationRepository)
        }

        container.register(NotificationPermissionInterface.self) { _ in
            NotificationPermissionService()
        }
    }
}
