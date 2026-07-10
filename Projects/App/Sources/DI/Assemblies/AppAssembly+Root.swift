//
//  AppAssembly+Root.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Root
import SplashInterface
import SignInInterface
import OnBoardingInterface
import ModyGroupInterface
import Swinject

extension AppAssembly {
    func assembleRoot(in container: Container) {
        container.register(RootCoordinator.self) { (resolver: Resolver, delegate: RootCoordinatorDelegate) in
            let splashBuilder: SplashBuildable = resolver.resolve()
            let signInBuilder: SignInBuildable = resolver.resolve()
            let onBoardingBuilder: OnBoardingBuildable = resolver.resolve()
            let modyGroupBuilder: ModyGroupBuildable = resolver.resolve()

            return RootCoordinator(
                splashBuilder: splashBuilder,
                signInBuilder: signInBuilder,
                onBoardingBuilder: onBoardingBuilder,
                modyGroupBuilder: modyGroupBuilder,
                delegate: delegate
            )
        }
    }
}
