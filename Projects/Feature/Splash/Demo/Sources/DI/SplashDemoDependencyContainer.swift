//
//  SplashDemoDependencyContainer.swift
//  SplashDemo
//
//  Created by 김동준 on 9/29/26.
//

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
                authUseCase: SplashDemoAuthUseCaseStub(scenario: scenario),
                analyticsUseCase: SplashDemoAnalyticsUseCaseStub(),
                router: { route in
                    router.route(from: route)
                }
            )
        }
    }

    func makeSplashRouter() -> SplashRouter {
        SplashDemoRouter()
    }
}
