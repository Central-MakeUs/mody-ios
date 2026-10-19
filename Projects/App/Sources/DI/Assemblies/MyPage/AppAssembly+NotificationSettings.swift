//
//  AppAssembly+NotificationSettings.swift
//  Mody
//
//  Created by 김동준 on 7/17/26
//

import CoreNotificationInterface
import CoreNetworkInterface
import MyPage
import MyPageInterface
import Swinject

extension AppAssembly {
    func assembleMyPageNotificationSettingsFeatures(in container: Container) {
        container.register(MyPageNotificationSettingRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return MyPageNotificationSettingRepository(network: network)
        }

        container.register(MyPageNotificationSettingUseCase.self) { resolver in
            let repository: MyPageNotificationSettingRepositoryProtocol = resolver.resolve()

            return MyPageNotificationSettingUseCase(repository: repository)
        }

        container.register(NotificationSettingsFeature.self) {
            (resolver: Resolver, router: MyPageNotificationSettingsRouter) in
            let notificationPermission: NotificationPermissionInterface = resolver.resolve()
            let notificationSettingUseCase: MyPageNotificationSettingUseCase = resolver.resolve()

            return NotificationSettingsFeature(
                notificationPermission: notificationPermission,
                notificationSettingUseCase: notificationSettingUseCase,
                router: { [weak router] route in
                    router?.route(from: route)
                }
            )
        }
    }
}
