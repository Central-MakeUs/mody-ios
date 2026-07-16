//
//  AppAssembly+GroupSettings.swift
//  Mody
//
//  Created by 김동준 on 7/17/26
//

import MyPage
import MyPageInterface
import Swinject

extension AppAssembly {
    func assembleMyPageGroupSettingsFeatures(in container: Container) {
        container.register(GroupSettingsFeature.self) {
            (_: Resolver, router: MyPageGroupSettingsRouter) in
            GroupSettingsFeature { [weak router] route in
                router?.route(from: route)
            }
        }
    }
}
