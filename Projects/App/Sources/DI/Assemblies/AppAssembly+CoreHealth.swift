//
//  AppAssembly+CoreHealth.swift
//  Mody
//
//  Created by 김동준 on 8/4/26.
//

import CoreHealth
import CoreHealthInterface
import Swinject

extension AppAssembly {
    func assembleCoreHealth(in container: Container) {
        container.register(HealthService.self) { _ in
            HealthService()
        }

        container.register(HealthRepositoryProtocol.self) { resolver in
            let healthService: HealthService = resolver.resolve()

            return HealthRepository(healthService: healthService)
        }

        container.register(HealthUseCaseProtocol.self) { resolver in
            let healthRepository: HealthRepositoryProtocol = resolver.resolve()

            return HealthUseCase(healthRepository: healthRepository)
        }

        container.register(HealthPermissionInterface.self) { _ in
            HealthPermissionService()
        }
    }
}
