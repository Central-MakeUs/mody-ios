//
//  AppAssembly+HealthDataSettings.swift
//  Mody
//
//  Created by 김동준 on 7/17/26
//

import CoreHealthInterface
import MyPage
import MyPageInterface
import Swinject

extension AppAssembly {
    func assembleMyPageHealthDataSettingsFeatures(in container: Container) {
        container.register(HealthDataSettingsFeature.self) {
            (resolver: Resolver, router: MyPageHealthDataSettingsRouter) in
            let healthPermissionInterface: HealthPermissionInterface = resolver.resolve()

            return HealthDataSettingsFeature(
                healthPermissionInterface: healthPermissionInterface
            ) { [weak router] route in
                router?.route(from: route)
            }
        }
    }
}
