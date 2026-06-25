//
//  AppAssembly+Splash.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject
import SplashInterface
import Splash

extension AppAssembly {
    func assembleSplashFeature(in container: Container) {
        container.register(SplashFeature.self) { (resolver: Resolver, router: SplashRouter) in
            return SplashFeature { [weak router] route in
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
