//
//  SplashDemoDependencyContainer.swift
//  SplashDemo
//
//  Created by 김동준 on 9/29/26.
//

import Splash
import SplashInterface
import SplashTesting

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
                authUseCase: SplashAuthUseCaseStub(
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
