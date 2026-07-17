//
//  AppAssembly+HealthDataSettings.swift
//  Mody
//
//  Created by 김동준 on 7/17/26
//

import MyPage
import MyPageInterface
import Swinject

extension AppAssembly {
    func assembleMyPageHealthDataSettingsFeatures(in container: Container) {
        container.register(HealthDataSettingsFeature.self) {
            (_: Resolver, router: MyPageHealthDataSettingsRouter) in
            HealthDataSettingsFeature { [weak router] route in
                router?.route(from: route)
            }
        }
    }
}
