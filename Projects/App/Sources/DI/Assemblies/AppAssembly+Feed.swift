//
//  AppAssembly+Feed.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import CoreCameraInterface
import CoreNetworkInterface
import FeedInterface
import Feed
import ModyGroupInterface

extension AppAssembly {
    func assembleFeedReactor(in container: Container) {
        container.register(FeedRepositoryProtocol.self) { resolver in
            let network: CoreNetworkProtocol = resolver.resolve()

            return FeedRepository(network: network)
        }

        container.register(FeedUseCaseProtocol.self) { resolver in
            let repository: FeedRepositoryProtocol = resolver.resolve()

            return FeedUseCase(feedRepository: repository)
        }

        container.register(FeedReactor.self) { (resolver: Resolver, router: FeedRouter) in
            let groupUseCase: GroupUseCaseProtocol = resolver.resolve()
            let feedUseCase: FeedUseCaseProtocol = resolver.resolve()

            return FeedReactor(
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
