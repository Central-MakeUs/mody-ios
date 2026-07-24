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

    public init(
        feedBuilder: FeedBuildable,
        challengeBuilder: ChallengeBuildable,
        myPageBuilder: MyPageBuildable,
        modyGroupBuilder: ModyGroupBuildable,
        notificationUseCase: NotificationUseCaseProtocol
    ) {
        self.feedBuilder = feedBuilder
        self.challengeBuilder = challengeBuilder
        self.myPageBuilder = myPageBuilder
        self.modyGroupBuilder = modyGroupBuilder
        self.notificationUseCase = notificationUseCase
    }

    @MainActor
    public func makeMainCoordinator(delegate: MainCoordinatorDelegate) -> MainCoordinating {
        MainCoordinator(
            feedBuilder: feedBuilder,
            challengeBuilder: challengeBuilder,
            myPageBuilder: myPageBuilder,
            modyGroupBuilder: modyGroupBuilder,
            notificationUseCase: notificationUseCase,
            delegate: delegate
        )
    }
}
