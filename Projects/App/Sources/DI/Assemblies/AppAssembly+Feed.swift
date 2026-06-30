//
//  AppAssembly+Feed.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import FeedInterface
import Feed

extension AppAssembly {
    func assembleFeedReactor(in container: Container) {
        container.register(FeedBuildable.self) { _ in
            return FeedBuilder()
        }
    }
}
