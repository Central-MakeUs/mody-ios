//
//  SplashDemoDependencyContainer.swift
//  SplashDemo
//
//  Created by 김동준 on 9/29/26.
//

import CoreAuthTesting
import Splash
import SplashInterface

@MainActor
final class SplashDemoDependencyContainer {
    func makeSplashBuilder(for scenario: SplashScenario) -> SplashBuildable {
        SplashBuilder { router in
            SplashFeature(
                splashUseCase: SplashUseCase(
                    splashRepository: SplashDemoRepositoryStub(
                        scenario: scenario
                    )
                ),
                authUseCase: AuthUseCaseStub(
                    userInfoResult: scenario.userInfoResult,
                    responseDelay: .milliseconds(700)
                ),
                router: { route in
                    router.route(from: route)
                }
            )
        }
    }
}
