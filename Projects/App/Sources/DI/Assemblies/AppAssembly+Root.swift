//
//  AppAssembly+Root.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Root
import SplashInterface
import Swinject

extension AppAssembly {
    func assembleRoot(in container: Container) {
        container.register(RootCoordinator.self) { (resolver: Resolver, delegate: RootCoordinatorDelegate) in
            let splashBuilder: SplashBuildable = resolver.resolve()
            return RootCoordinator(
                splashBuilder: splashBuilder,
                delegate: delegate
            )
        }
    }
}
