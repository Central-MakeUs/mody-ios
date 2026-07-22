//
//  AppAssembly+Feed.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import CoreAuthInterface
import CoreCameraInterface
import FeedInterface
import Feed
import ModyGroupInterface
import CoreNetworkInterface

extension AppAssembly {
    func assembleFeedReactor(in container: Container) {
        container.register(FeedRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return FeedRepository(network: network)
        }

        container.register(FeedUseCase.self) { resolver in
            let feedRepository: FeedRepositoryProtocol = resolver.resolve()

            return FeedUseCase(feedRepository: feedRepository)
        }

        container.register(FeedReactor.self) { (resolver: Resolver, router: FeedRouter) in
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()
            let groupUseCase: GroupUseCaseProtocol = resolver.resolve()
            let feedUseCase: FeedUseCase = resolver.resolve()

            return FeedReactor(
                authUseCase: authUseCase,
                groupUseCase: groupUseCase,
                feedUseCase: feedUseCase,
                router: router
            )
        }
        
        container.register(FeedBuildable.self) { resolver in
            let makeFeedRecordReactor: (FeedRecordRouter, FeedRecordType) -> FeedRecordReactor = resolver.resolve()
            let cameraCaptureBuilder: CameraCaptureBuildable = resolver.resolve()

            return FeedBuilder(
                makeFeedReactor: { router in
                    resolver.resolve(argument: router)
                },
                makeFeedRecordReactor: makeFeedRecordReactor,
                cameraCaptureBuilder: cameraCaptureBuilder
            )
        }
    }
}
