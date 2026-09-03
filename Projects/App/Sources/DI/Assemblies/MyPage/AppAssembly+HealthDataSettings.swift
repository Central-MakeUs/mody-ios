//
//  AppAssembly+HealthDataSettings.swift
//  Mody
//
//  Created by 김동준 on 7/17/26
//

import CoreHealthInterface
import CoreAnalyticsInterface
import MyPage
import MyPageInterface
import Swinject

extension AppAssembly {
    func assembleMyPageHealthDataSettingsFeatures(in container: Container) {
        container.register(HealthDataSettingsFeature.self) {
            (resolver: Resolver, router: MyPageHealthDataSettingsRouter) in
            let healthPermissionInterface: HealthPermissionInterface = resolver.resolve()
            let analyticsUseCase: AnalyticsUseCaseProtocol = resolver.resolve()

            return HealthDataSettingsFeature(
                healthPermissionInterface: healthPermissionInterface,
                analyticsUseCase: analyticsUseCase
            ) { [weak router] route in
                router?.route(from: route)
            }
        }
    }
}
