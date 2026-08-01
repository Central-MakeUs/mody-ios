//
//  AppAssembly+Challenge.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import ChallengeInterface
import Challenge
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

        container.register(ChallengeFeature.self) { (resolver: Resolver, router: ChallengeRouter) in
            let challengeUseCase: ChallengeUseCase = resolver.resolve()

            return ChallengeFeature(challengeUseCase: challengeUseCase) { [weak router] route in
                router?.route(from: route)
            }
        }

        container.register(ChallengeBuildable.self) { resolver in
            return ChallengeBuilder(
                makeChallengeFeature: { router in
                    resolver.resolve(argument: router)
                }
            )
        }
    }
}
