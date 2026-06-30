//
//  MainCoordinator.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import Base
import UIKit
import FeedInterface
import ChallengeInterface
import MyPageInterface

public final class MainCoordinator {
    public let navigationController: UINavigationController
    public let tabBarController: MainTabBarController
    public weak var delegate: MainCoordinatorDelegate?

    private let feedBuilder: FeedBuildable
    private let challengeBuilder: ChallengeBuildable
    private let myPageBuilder: MyPageBuildable

    public init(
        navigationController: UINavigationController = SwipeBackNavigationController(),
        tabBarController: MainTabBarController = MainTabBarController(),
        feedBuilder: FeedBuildable,
        challengeBuilder: ChallengeBuildable,
        myPageBuilder: MyPageBuildable,
        delegate: MainCoordinatorDelegate? = nil
    ) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        self.feedBuilder = feedBuilder
        self.challengeBuilder = challengeBuilder
        self.myPageBuilder = myPageBuilder
        self.delegate = delegate
        navigationController.setNavigationBarHidden(true, animated: false)
        print("⭕ MainCoordinator init!")
    }

    deinit {
        print("❎ MainCoordinator deinit!")
    }

    @MainActor
    public func start() {
        let feedViewController = feedBuilder.makeFeedViewController(router: self)
        let challengeViewController = challengeBuilder.makeChallengeViewController(router: self)
        let myPageViewController = myPageBuilder.makeMyPageViewController(router: self)

        let isChallengeHideFlag = true
        let viewControllers = isChallengeHideFlag
            ? [feedViewController, myPageViewController]
            : [feedViewController, challengeViewController, myPageViewController]
        
        let tabs: [MainTab] = isChallengeHideFlag
            ? [.dashboard, .myPage]
            : [.dashboard, .challenge, .myPage]
        
        tabBarController.setTabs(
            tabs: tabs,
            viewControllers: viewControllers,
            animated: false
        )

        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
