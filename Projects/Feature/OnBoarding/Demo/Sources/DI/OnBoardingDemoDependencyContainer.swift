//
//  OnBoardingDemoDependencyContainer.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import OnBoarding
import OnBoardingInterface
import OnBoardingTesting

@MainActor
final class OnBoardingDemoDependencyContainer {
    func makeOnBoardingBuilder(for scenario: OnBoardingScenario) -> OnBoardingBuildable {
        OnBoardingBuilder { router in
            let permission = OnBoardingPermissionStub(
                shouldPromptForHealth: scenario.shouldPromptForHealth,
                requestResult: scenario.permissionRequestResult
            )
            return OnBoardingFeature(
                onBoardingUseCase: OnBoardingUseCase(
                    onBoardingRepository: OnBoardingDemoRepositoryStub(
                        result: scenario.profileResult
                    )
                ),
                cameraPermission: permission,
                notificationPermission: permission,
                healthPermission: permission,
                analyticsUseCase: OnBoardingAnalyticsUseCaseStub(),
                router: { route in router.route(from: route) }
            )
        }
    }
}
