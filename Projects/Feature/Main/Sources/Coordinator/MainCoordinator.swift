//
//  MainCoordinator.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import Base
import UIKit
import MainInterface
import FeedInterface
import ChallengeInterface
import MyPageInterface
import ModyGroupInterface
import CommonDomain
import CoreModyImageInterface

public final class MainCoordinator: MainCoordinating {
    public let navigationController: UINavigationController
    public let tabBarController: MainTabBarController
    weak var delegate: MainCoordinatorDelegate?
    weak var mainContainerViewController: MainContainerViewController?
    weak var feedInputHandler: FeedInputHandler?
    weak var challengeInputHandler: ChallengeInputHandler?
    weak var myPageInputHandler: MyPageInputHandler?

    let feedBuilder: FeedBuildable
    let challengeBuilder: ChallengeBuildable
    let myPageBuilder: MyPageBuildable
    let modyGroupBuilder: ModyGroupBuildable
    private let mainContainerBuilder: MainContainerBuildable
    let notificationBuilder: NotificationBuildable
    let imageLoader: RemoteImageLoading

    init(
        navigationController: UINavigationController = SwipeBackNavigationController(),
        tabBarController: MainTabBarController = MainTabBarController(),
        feedBuilder: FeedBuildable,
        challengeBuilder: ChallengeBuildable,
        myPageBuilder: MyPageBuildable,
        modyGroupBuilder: ModyGroupBuildable,
        mainContainerBuilder: MainContainerBuildable,
        notificationBuilder: NotificationBuildable,
        imageLoader: RemoteImageLoading,
        delegate: MainCoordinatorDelegate
    ) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        self.feedBuilder = feedBuilder
        self.challengeBuilder = challengeBuilder
        self.myPageBuilder = myPageBuilder
        self.modyGroupBuilder = modyGroupBuilder
        self.mainContainerBuilder = mainContainerBuilder
        self.notificationBuilder = notificationBuilder
        self.imageLoader = imageLoader
        self.delegate = delegate
        navigationController.setNavigationBarHidden(true, animated: false)
        print("⭕ MainCoordinator init!")
    }

    deinit {
        print("❎ MainCoordinator deinit!")
    }

    @MainActor
    public func start() {
        let feedViewController = feedBuilder.makeFeedViewController(
            router: self,
            outputHandler: self
        )
        feedInputHandler = feedViewController as? FeedInputHandler
        let challengeViewController = challengeBuilder.makeChallengeViewController(
            router: self,
            outputHandler: self
        )
        challengeInputHandler = challengeViewController as? ChallengeInputHandler
        let myPageViewController = myPageBuilder.makeMyPageViewController(
            router: self,
            outputHandler: self
        )
        myPageInputHandler = myPageViewController

        let isPhaseOne = PhaseManager.shared.isPhaseOne
        let viewControllers = isPhaseOne
            ? [feedViewController, myPageViewController]
            : [feedViewController, challengeViewController, myPageViewController]
        
        let tabs: [MainTab] = isPhaseOne
            ? [.feed, .myPage]
            : [.feed, .challenge, .myPage]
        
        tabBarController.setTabs(
            tabs: tabs,
            viewControllers: viewControllers,
            animated: false
        )

        let mainContainerViewController = mainContainerBuilder.makeMainContainerViewController(
            tabBarController: tabBarController,
            tabs: tabs
        )
        self.mainContainerViewController = mainContainerViewController
        mainContainerViewController.onGroupParticipateTap = { [weak self] in
            self?.showGroupParticipate()
        }
        mainContainerViewController.onGroupCreateTap = { [weak self] in
            self?.showGroupCreate(needBackButton: true)
        }
        mainContainerViewController.onAlarmTap = { [weak self] in
            self?.showNotification()
        }

        navigationController.setViewControllers([mainContainerViewController], animated: false)
    }
}
