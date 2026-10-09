//
//  OnBoardingDemoDependencyContainer.swift
//  OnBoardingDemo
//
//  Created by 김동준 on 10/4/26.
//

import CoreCameraTesting
import CoreHealthTesting
import CoreNetworkTesting
import CoreNotificationTesting
import OnBoarding
import OnBoardingInterface

@MainActor
final class OnBoardingDemoDependencyContainer {
    func makeOnBoardingBuilder(for scenario: OnBoardingScenario) -> OnBoardingBuildable {
        OnBoardingBuilder { router in
            let notificationPermission = NotificationPermissionStub(
                isNotDetermined: true,
                isGranted: scenario.permissionRequestResult,
                requestResult: scenario.permissionRequestResult
            )
            return OnBoardingFeature(
                onBoardingUseCase: OnBoardingUseCase(
                    onBoardingRepository: OnBoardingRepository(network: CoreNetworkStub(responseDelay: .milliseconds(500)) { endpoint in
                        try scenario.networkResponse(to: endpoint)
                    })
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
