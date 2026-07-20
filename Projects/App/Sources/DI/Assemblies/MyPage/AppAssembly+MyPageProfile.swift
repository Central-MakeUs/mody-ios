//
//  AppAssembly+MyPageProfile.swift
//  Mody
//
//  Created by 김동준 on 7/12/26.
//

import Swinject
import CoreAuthInterface
import MyPageInterface
import MyPage

extension AppAssembly {
    func assembleMyPageProfileFeature(in container: Container) {
        container.register(ProfileFeature.self) { (resolver: Resolver, router: MyPageProfileRouter) in
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()
            let myPageUseCase: MyPageUseCase = resolver.resolve()

            return ProfileFeature(
                authUseCase: authUseCase,
                myPageUseCase: myPageUseCase
            ) { [weak router] route in
                router?.route(from: route)
            }
        }
    }
}
