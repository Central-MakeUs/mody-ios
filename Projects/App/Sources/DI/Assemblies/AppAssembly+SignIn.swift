//
//  AppAssembly+SignIn.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject
import CoreAnalyticsInterface
import CoreAuthInterface
import FirebaseServiceInterface
import SignInInterface
import SignIn

extension AppAssembly {
    func assembleSignInFeature(in container: Container) {
        container.register(SignInRepositoryProtocol.self) { resolver in
            let firebaseService: FirebaseServiceInterface = resolver.resolve()

            return SignInRepository(firebaseService: firebaseService)
        }

        container.register(SignInUseCase.self) { resolver in
            let signInRepository: SignInRepositoryProtocol = resolver.resolve()

            return SignInUseCase(signInRepository: signInRepository)
        }

        container.register(SignInFeature.self) { (resolver: Resolver, router: SignInRouter) in
            let signInUseCase: SignInUseCase = resolver.resolve()
            let socialLoginUseCase: SocialLoginInterface = resolver.resolve()
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()
            let analyticsUseCase: AnalyticsUseCaseProtocol = resolver.resolve()

            return SignInFeature(
                signInUseCase: signInUseCase,
                socialLoginUseCase: socialLoginUseCase,
                authUseCase: authUseCase,
                analyticsUseCase: analyticsUseCase
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
