//
//  AppAssembly+NotificationSettings.swift
//  Mody
//
//  Created by 김동준 on 7/17/26
//

import MyPage
import MyPageInterface
import Swinject

extension AppAssembly {
    func assembleMyPageNotificationSettingsFeatures(in container: Container) {
        container.register(NotificationSettingsFeature.self) {
            (_: Resolver, router: MyPageNotificationSettingsRouter) in
            NotificationSettingsFeature { [weak router] route in
                router?.route(from: route)
            }
        }
    }
}
