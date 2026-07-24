//
//  MainBuilder.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import ChallengeInterface
import CoreNotificationInterface
import FeedInterface
import MainInterface
import ModyGroupInterface
import MyPageInterface

public struct MainBuilder: MainBuildable {
    private let feedBuilder: FeedBuildable
    private let challengeBuilder: ChallengeBuildable
    private let myPageBuilder: MyPageBuildable
    private let modyGroupBuilder: ModyGroupBuildable
    private let notificationUseCase: NotificationUseCaseProtocol
    private let makeMainReactor: () -> MainReactor

    public init(
        feedBuilder: FeedBuildable,
        challengeBuilder: ChallengeBuildable,
        myPageBuilder: MyPageBuildable,
        modyGroupBuilder: ModyGroupBuildable,
        notificationUseCase: NotificationUseCaseProtocol,
        makeMainReactor: @escaping () -> MainReactor
    ) {
        self.feedBuilder = feedBuilder
        self.challengeBuilder = challengeBuilder
        self.myPageBuilder = myPageBuilder
        self.modyGroupBuilder = modyGroupBuilder
        self.notificationUseCase = notificationUseCase
        self.makeMainReactor = makeMainReactor
    }

    @MainActor
    public func makeMainCoordinator(delegate: MainCoordinatorDelegate) -> MainCoordinating {
        let mainContainerBuilder = MainContainerBuilder(makeMainReactor: makeMainReactor)
        let notificationBuilder = NotificationBuilder(notificationUseCase: notificationUseCase)

        return MainCoordinator(
            feedBuilder: feedBuilder,
            challengeBuilder: challengeBuilder,
            myPageBuilder: myPageBuilder,
            modyGroupBuilder: modyGroupBuilder,
            mainContainerBuilder: mainContainerBuilder,
            notificationBuilder: notificationBuilder,
            delegate: delegate
        )
    }
}
