//
//  MainBuilder.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

import ChallengeInterface
import CoreAnalyticsInterface
import CoreNotificationInterface
import CoreModyImageInterface
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
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private let imageLoader: RemoteImageLoading
    private let makeMainReactor: () -> MainReactor

    public init(
        feedBuilder: FeedBuildable,
        challengeBuilder: ChallengeBuildable,
        myPageBuilder: MyPageBuildable,
        modyGroupBuilder: ModyGroupBuildable,
        notificationUseCase: NotificationUseCaseProtocol,
        analyticsUseCase: AnalyticsUseCaseProtocol,
        imageLoader: RemoteImageLoading,
        makeMainReactor: @escaping () -> MainReactor
    ) {
        self.feedBuilder = feedBuilder
        self.challengeBuilder = challengeBuilder
        self.myPageBuilder = myPageBuilder
        self.modyGroupBuilder = modyGroupBuilder
        self.notificationUseCase = notificationUseCase
        self.analyticsUseCase = analyticsUseCase
        self.imageLoader = imageLoader
        self.makeMainReactor = makeMainReactor
    }

    @MainActor
    public func makeMainCoordinator(delegate: MainCoordinatorDelegate) -> MainCoordinating {
        let mainContainerBuilder = MainContainerBuilder(makeMainReactor: makeMainReactor)
        let notificationBuilder = NotificationBuilder(
            notificationUseCase: notificationUseCase,
            analyticsUseCase: analyticsUseCase
        )

        return MainCoordinator(
            feedBuilder: feedBuilder,
            challengeBuilder: challengeBuilder,
            myPageBuilder: myPageBuilder,
            modyGroupBuilder: modyGroupBuilder,
            mainContainerBuilder: mainContainerBuilder,
            notificationBuilder: notificationBuilder,
            imageLoader: imageLoader,
            analyticsUseCase: analyticsUseCase,
            delegate: delegate
        )
    }
}
