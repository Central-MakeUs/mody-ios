//
//  AppAssembly+SignIn.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject
import CoreAuthInterface
import SignInInterface
import SignIn

extension AppAssembly {
    func assembleSignInFeature(in container: Container) {
        container.register(SignInFeature.self) { (resolver: Resolver, router: SignInRouter) in
            let socialLoginUseCase: SocialLoginInterface = resolver.resolve()
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()

            return SignInFeature(
                socialLoginUseCase: socialLoginUseCase,
                authUseCase: authUseCase
            ) { [weak router] route in
                router?.route(from: route)
            }
        }
        
        container.register(SignInBuildable.self) { resolver in
            return SignInBuilder(
                makeSignInFeature: { router in
                    resolver.resolve(argument: router)
                }
            )
        }
    }
}
