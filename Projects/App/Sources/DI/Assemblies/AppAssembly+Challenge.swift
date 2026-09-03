//
//  AppAssembly+Challenge.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import ChallengeInterface
import Challenge
import CoreAnalyticsInterface
import CoreAuthInterface
import CoreCameraInterface
import CoreHealthInterface
import CoreModyImageInterface
import CoreNetworkInterface

extension AppAssembly {
    func assembleChallengeFeature(in container: Container) {
        container.register(ChallengeRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return ChallengeRepository(network: network)
        }

        container.register(ChallengeUseCase.self) { resolver in
            let repository: ChallengeRepositoryProtocol = resolver.resolve()

            return ChallengeUseCase(repository: repository)
        }

        container.register(ChallengeFeature.self) { (
            resolver: Resolver,
            arguments: (ChallengeRouter, ChallengeOutputHandler)
        ) in
            let (router, outputHandler) = arguments
            let challengeUseCase: ChallengeUseCase = resolver.resolve()
            let healthUseCase: HealthUseCaseProtocol = resolver.resolve()
            let analyticsUseCase: AnalyticsUseCaseProtocol = resolver.resolve()

            return ChallengeFeature(
                challengeUseCase: challengeUseCase,
                healthUseCase: healthUseCase,
                analyticsUseCase: analyticsUseCase,
                router: { [weak router] route in
                    router?.route(from: route)
                },
                output: { [weak outputHandler] output in
                    outputHandler?.handle(output: output)
                }
            )
        }

        container.register(ChallengeChangeFeature.self) { (
            resolver: Resolver,
            arguments: (ChallengeChangeRouter, ChallengeOutputHandler)
        ) in
            let (router, outputHandler) = arguments
            let challengeUseCase: ChallengeUseCase = resolver.resolve()

            return ChallengeChangeFeature(
                challengeUseCase: challengeUseCase,
                router: { [weak router] route in
                    router?.route(from: route)
                },
                output: { [weak outputHandler] output in
                    outputHandler?.handle(output: output)
                }
            )
        }

        container.register(ChallengeWeeklyDetailFeature.self) { (
            resolver: Resolver,
            arguments: (ChallengeWeeklyDetailRouter, ChallengeOutputHandler)
        ) in
            let (router, outputHandler) = arguments
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()
            let challengeUseCase: ChallengeUseCase = resolver.resolve()
            let imageUploadUseCase: ImageUploadUseCaseProtocol = resolver.resolve()
            let temporaryImageFileUseCase: TemporaryImageFileUseCaseProtocol = resolver.resolve()
            let analyticsUseCase: AnalyticsUseCaseProtocol = resolver.resolve()

            return ChallengeWeeklyDetailFeature(
                authUseCase: authUseCase,
                challengeUseCase: challengeUseCase,
                imageUploadUseCase: imageUploadUseCase,
                temporaryImageFileUseCase: temporaryImageFileUseCase,
                analyticsUseCase: analyticsUseCase,
                router: { [weak router] route in
                    router?.route(from: route)
                },
                output: { [weak outputHandler] output in
                    outputHandler?.handle(output: output)
                }
            )
        }

        container.register(ChallengeBuildable.self) { resolver in
            let imageLoader: RemoteImageLoading = resolver.resolve()
            let cameraCaptureBuilder: CameraCaptureBuildable = resolver.resolve()

            return ChallengeBuilder(
                makeChallengeFeature: { router, outputHandler in
                    resolver.resolve(argument: (router, outputHandler))
                },
                makeChallengeChangeFeature: { router, outputHandler in
                    resolver.resolve(argument: (router, outputHandler))
                },
                makeChallengeWeeklyDetailFeature: { router, outputHandler in
                    resolver.resolve(argument: (router, outputHandler))
                },
                imageLoader: imageLoader,
                cameraCaptureBuilder: cameraCaptureBuilder
            )
        }
    }
}
