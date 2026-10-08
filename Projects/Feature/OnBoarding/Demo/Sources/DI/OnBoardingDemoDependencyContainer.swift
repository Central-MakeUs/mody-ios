//
//  OnBoardingDemoDependencyContainer.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import CoreCameraTesting
import CoreHealthTesting
import OnBoarding
import OnBoardingInterface
import OnBoardingTesting

@MainActor
final class OnBoardingDemoDependencyContainer {
    func makeOnBoardingBuilder(for scenario: OnBoardingScenario) -> OnBoardingBuildable {
        OnBoardingBuilder { router in
            let notificationPermission = OnBoardingNotificationPermissionStub(
                requestResult: scenario.permissionRequestResult
            )
            return OnBoardingFeature(
                onBoardingUseCase: OnBoardingUseCase(
                    onBoardingRepository: OnBoardingDemoRepositoryStub(
                        result: scenario.profileResult
                    )
                ),
                cameraPermission: CameraPermissionStub(
                    isNotDetermined: true,
                    isGranted: scenario.permissionRequestResult,
                    requestResult: scenario.permissionRequestResult
                ),
                notificationPermission: notificationPermission,
                healthPermission: HealthPermissionStub(
                    shouldShowPrompt: scenario.shouldPromptForHealth,
                    requestResult: scenario.permissionRequestResult
                ),
                router: { route in router.route(from: route) }
            )
        }
    }
}
