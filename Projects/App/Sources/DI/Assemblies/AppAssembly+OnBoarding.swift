//
//  AppAssembly+OnBoarding.swift
//  Mody
//
//  Created by 김동준 on 6/25/26
//

import Swinject
import OnBoardingInterface
import OnBoarding
import CoreCameraInterface
import CoreNetworkInterface
import CoreNotificationInterface
import CoreHealthInterface

extension AppAssembly {
    func assembleOnBoardingFeature(in container: Container) {
        container.register(OnBoardingRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return OnBoardingRepository(network: network)
        }

        container.register(OnBoardingUseCase.self) { resolver in
            let repository: OnBoardingRepositoryProtocol = resolver.resolve()

            return OnBoardingUseCase(onBoardingRepository: repository)
        }

        container.register(OnBoardingFeature.self) { (resolver: Resolver, router: OnBoardingRouter) in
            let onBoardingUseCase: OnBoardingUseCase = resolver.resolve()
            let cameraPermission: CameraPermissionInterface = resolver.resolve()
            let notificationPermission: NotificationPermissionInterface = resolver.resolve()
            let healthPermission: HealthPermissionInterface = resolver.resolve()

            return OnBoardingFeature(
                onBoardingUseCase: onBoardingUseCase,
                cameraPermission: cameraPermission,
                notificationPermission: notificationPermission,
                healthPermission: healthPermission
            ) { [weak router] route in
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
