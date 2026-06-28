//
//  AppAssembly+OnBoarding.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject
import OnBoardingInterface
import OnBoarding

extension AppAssembly {
    func assembleOnBoardingFeature(in container: Container) {
        container.register(OnBoardingFeature.self) { (resolver: Resolver, router: OnBoardingRouter) in
            return OnBoardingFeature { [weak router] route in
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
