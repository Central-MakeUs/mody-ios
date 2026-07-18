//
//  AppAssembly+NotificationSettings.swift
//  Mody
//
//  Created by 김동준 on 7/17/26
//

import CoreNotificationInterface
import MyPage
import MyPageInterface
import Swinject

extension AppAssembly {
    func assembleMyPageNotificationSettingsFeatures(in container: Container) {
        container.register(NotificationSettingsFeature.self) {
            (resolver: Resolver, router: MyPageNotificationSettingsRouter) in
            let notificationPermission: NotificationPermissionInterface = resolver.resolve()

            return NotificationSettingsFeature(
                notificationPermission: notificationPermission,
                router: { [weak router] route in
                    router?.route(from: route)
                }
            )
        }
    }
}
