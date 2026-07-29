//
//  AppAssembly+Feed.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import CoreAuthInterface
import CoreCameraInterface
import CoreModyImageInterface
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

        container.register(FeedReactor.self) {
            (resolver: Resolver, arguments: (FeedRouter, FeedOutputHandler)) in
            let authUseCase: AuthUseCaseProtocol = resolver.resolve()
            let groupUseCase: GroupUseCaseProtocol = resolver.resolve()
            let feedUseCase: FeedUseCase = resolver.resolve()
            let (router, outputHandler) = arguments

            return FeedReactor(
                authUseCase: authUseCase,
                groupUseCase: groupUseCase,
                feedUseCase: feedUseCase,
                router: router,
                output: { [weak outputHandler] output in
                    outputHandler?.handle(output: output)
                }
            )
        }
        
        container.register(FeedBuildable.self) { resolver in
            let makeFeedRecordReactor: (FeedRecordRouter, FeedRecordType, FeedRecordOutputHandler) -> FeedRecordReactor = resolver.resolve()
            let cameraCaptureBuilder: CameraCaptureBuildable = resolver.resolve()
            let imageLoader: RemoteImageLoading = resolver.resolve()

            return FeedBuilder(
                makeFeedReactor: { router, outputHandler in
                    resolver.resolve(argument: (router, outputHandler))
                },
                makeFeedRecordReactor: makeFeedRecordReactor,
                cameraCaptureBuilder: cameraCaptureBuilder,
                imageLoader: imageLoader
            )
        }
    }
}
