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
import ModyGroupInterface
import CommonDomain

public final class MainCoordinator {
    public let navigationController: UINavigationController
    public let tabBarController: MainTabBarController
    public weak var delegate: MainCoordinatorDelegate?
    weak var mainContainerViewController: MainContainerViewController?
    weak var myPageInputHandler: MyPageInputHandler?

    let feedBuilder: FeedBuildable
    private let challengeBuilder: ChallengeBuildable
    let myPageBuilder: MyPageBuildable
    let modyGroupBuilder: ModyGroupBuildable

    public init(
        navigationController: UINavigationController = SwipeBackNavigationController(),
        tabBarController: MainTabBarController = MainTabBarController(),
        feedBuilder: FeedBuildable,
        challengeBuilder: ChallengeBuildable,
        myPageBuilder: MyPageBuildable,
        modyGroupBuilder: ModyGroupBuildable,
        delegate: MainCoordinatorDelegate? = nil
    ) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        self.feedBuilder = feedBuilder
        self.challengeBuilder = challengeBuilder
        self.myPageBuilder = myPageBuilder
        self.modyGroupBuilder = modyGroupBuilder
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

        let mainContainerViewController = MainContainerViewController(
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

        navigationController.setViewControllers([mainContainerViewController], animated: false)
    }
}
