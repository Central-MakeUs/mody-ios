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
        container.register(FeedReactor.self) { resolver in
            let groupUseCase: GroupUseCaseProtocol = resolver.resolve()

            return FeedReactor(groupUseCase: groupUseCase)
        }
        
        container.register(FeedBuildable.self) { resolver in
            return FeedBuilder(
                makeFeedReactor: {
                    resolver.resolve()
                }
            )
        }
    }
}
