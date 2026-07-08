//
//  AppAssembly+OnBoarding.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject
import OnBoardingInterface
import OnBoarding
import CoreNetworkInterface

extension AppAssembly {
    func assembleOnBoardingFeature(in container: Container) {
        container.register(OnBoardingRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return OnBoardingRepository(network: network)
        }

        container.register(OnBoardingUseCase.self) { resolver in
            let repository: OnBoardingRepositoryProtocol = resolver.resolve()

            return OnBoardingUseCase(onBoardingRepository: repository)
        }

        container.register(OnBoardingFeature.self) { (resolver: Resolver, router: OnBoardingRouter) in
            let onBoardingUseCase: OnBoardingUseCase = resolver.resolve()

            return OnBoardingFeature(onBoardingUseCase: onBoardingUseCase) { [weak router] route in
                router?.route(from: route)
            }
        }
        
        container.register(OnBoardingBuildable.self) { resolver in
            return OnBoardingBuilder(
                makeOnBoardingFeature: { router in
                    resolver.resolve(argument: router)
                }
            )
        }
    }
}
