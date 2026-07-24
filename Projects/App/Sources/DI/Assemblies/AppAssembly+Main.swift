//
//  AppAssembly+Main.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import Main
import FeedInterface
import ChallengeInterface
import MyPageInterface
import ModyGroupInterface
import CoreNotificationInterface

extension AppAssembly {
    func assembleMain(in container: Container) {
        container.register(MainCoordinator.self) { (resolver: Resolver, delegate: MainCoordinatorDelegate) in
            let feedBuilder: FeedBuildable = resolver.resolve()
            let challengeBuilder: ChallengeBuildable = resolver.resolve()
            let myPageBuilder: MyPageBuildable = resolver.resolve()
            let modyGroupBuilder: ModyGroupBuildable = resolver.resolve()
            let notificationUseCase: NotificationUseCaseProtocol = resolver.resolve()

            return MainCoordinator(
                feedBuilder: feedBuilder,
                challengeBuilder: challengeBuilder,
                myPageBuilder: myPageBuilder,
                modyGroupBuilder: modyGroupBuilder,
                notificationUseCase: notificationUseCase,
                delegate: delegate
            )
        }
    }
}
