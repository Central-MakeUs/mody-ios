//
//  AppAssembly+Main.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import Main
import FeedInterface
import MyPageInterface

extension AppAssembly {
    func assembleMain(in container: Container) {
        container.register(MainCoordinator.self) { (resolver: Resolver, delegate: MainCoordinatorDelegate) in
            let feedBuilder: FeedBuildable = resolver.resolve()
            let myPageBuilder: MyPageBuildable = resolver.resolve()

            return MainCoordinator(
                feedBuilder: feedBuilder,
                myPageBuilder: myPageBuilder,
                delegate: delegate
            )
        }
    }
}
