//
//  AppAssembly+Splash.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject
import SplashInterface
import Splash
import FirebaseServiceInterface
import CoreNetworkInterface
import CoreKeyChainStorage
import CoreKeyChainStorageInterface
import CoreAuthInterface

extension AppAssembly {
    func assembleSplashFeature(in container: Container) {
        container.register(SplashRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()
            let firebaseService: FirebaseServiceInterface = resolver.resolve()
            let keyChainStorage: CoreKeyChainStorageInterface = CoreKeyChainStorage()

            return SplashRepository(
                network: network,
                firebaseService: firebaseService,
                keyChainStorage: keyChainStorage
            )
        }

        container.register(SplashUseCase.self) { resolver in
            let splashRepository: SplashRepositoryProtocol = resolver.resolve()

            return SplashUseCase(splashRepository: splashRepository)
        }

        container.register(SplashFeature.self) { (resolver: Resolver, router: SplashRouter) in
            let splashUseCase: SplashUseCase = resolver.resolve()
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()

            return SplashFeature(
                splashUseCase: splashUseCase,
                authUseCase: authUseCase
            ) { [weak router] route in
                router?.route(from: route)
            }
        }
        
        container.register(SplashBuildable.self) { resolver in
            return SplashBuilder(
                makeSplashFeature: { router in
                    resolver.resolve(argument: router)
                }
            )
        }
    }
}
