//
//  AppAssembly+Feed.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import FeedInterface
import Feed
import ModyGroupInterface

extension AppAssembly {
    func assembleFeedReactor(in container: Container) {
        container.register(FeedReactor.self) { (resolver: Resolver, router: FeedRouter) in
            let groupUseCase: GroupUseCaseProtocol = resolver.resolve()

            return FeedReactor(
                groupUseCase: groupUseCase,
                router: router
            )
        }
        
        container.register(FeedBuildable.self) { resolver in
            let makeFeedRecordReactor: (FeedRecordRouter, FeedRecordType) -> FeedRecordReactor = resolver.resolve()

            return FeedBuilder(
                makeFeedReactor: { router in
                    resolver.resolve(argument: router)
                },
                makeFeedRecordReactor: makeFeedRecordReactor
            )
        }
    }
}
