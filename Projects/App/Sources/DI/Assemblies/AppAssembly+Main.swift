//
//  AppAssembly+Main.swift
//  Mody
//
//  Created by 김동준 on 6/30/26
//

import Swinject
import CoreAnalyticsInterface
import Main
import MainInterface
import FeedInterface
import ChallengeInterface
import MyPageInterface
import ModyGroupInterface
import CoreNotificationInterface
import CoreModyImageInterface

extension AppAssembly {
    func assembleMain(in container: Container) {
        container.register(MainReactor.self) { resolver in
            let notificationUseCase: NotificationUseCaseProtocol = resolver.resolve()

            return MainReactor(notificationUseCase: notificationUseCase)
        }

        container.register(MainBuildable.self) { resolver in
            let feedBuilder: FeedBuildable = resolver.resolve()
            let challengeBuilder: ChallengeBuildable = resolver.resolve()
            let myPageBuilder: MyPageBuildable = resolver.resolve()
            let modyGroupBuilder: ModyGroupBuildable = resolver.resolve()
            let notificationUseCase: NotificationUseCaseProtocol = resolver.resolve()
            let analyticsUseCase: AnalyticsUseCaseProtocol = resolver.resolve()
            let imageLoader: RemoteImageLoading = resolver.resolve()

            return MainBuilder(
                feedBuilder: feedBuilder,
                challengeBuilder: challengeBuilder,
                myPageBuilder: myPageBuilder,
                modyGroupBuilder: modyGroupBuilder,
                notificationUseCase: notificationUseCase,
                analyticsUseCase: analyticsUseCase,
                imageLoader: imageLoader,
                makeMainReactor: {
                    resolver.resolve()
                }
            )
        }
    }
}
