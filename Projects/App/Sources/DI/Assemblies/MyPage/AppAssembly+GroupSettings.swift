//
//  AppAssembly+GroupSettings.swift
//  Mody
//
//  Created by 김동준 on 7/17/26
//

import MyPage
import MyPageInterface
import ModyGroupInterface
import Swinject

extension AppAssembly {
    func assembleMyPageGroupSettingsFeatures(in container: Container) {
        container.register(GroupSettingsFeature.self) {
            (resolver: Resolver, arguments: (MyPageGroupSettingsRouter, MyPageOutputHandler)) in
            let (router, outputHandler) = arguments
            let groupUseCase: GroupUseCaseProtocol = resolver.resolve()

            return GroupSettingsFeature(
                groupUseCase: groupUseCase,
                router: { [weak router] route in
                    router?.route(from: route)
                },
                output: { [weak outputHandler] output in
                    outputHandler?.handle(output: output)
                }
            )
        }
    }
}
