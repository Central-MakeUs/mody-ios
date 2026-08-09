//
//  AppAssembly+Challenge.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import ChallengeInterface
import Challenge
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

            return ChallengeFeature(
                challengeUseCase: challengeUseCase,
                healthUseCase: healthUseCase,
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
            router: ChallengeChangeRouter
        ) in
            let challengeUseCase: ChallengeUseCase = resolver.resolve()

            return ChallengeChangeFeature(
                challengeUseCase: challengeUseCase,
                router: { [weak router] route in
                    router?.route(from: route)
                }
            )
        }

        container.register(ChallengeBuildable.self) { resolver in
            let imageLoader: RemoteImageLoading = resolver.resolve()

            return ChallengeBuilder(
                makeChallengeFeature: { router, outputHandler in
                    resolver.resolve(argument: (router, outputHandler))
                },
                makeChallengeChangeFeature: { router in
                    resolver.resolve(argument: router)
                },
                imageLoader: imageLoader
            )
        }
    }
}
