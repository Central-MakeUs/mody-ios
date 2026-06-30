//
//  MainCoordinator.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import Base
import UIKit
import FeedInterface
import MyPageInterface

public final class MainCoordinator {
    public let navigationController: UINavigationController
    public let tabBarController: MainTabBarController
    public weak var delegate: MainCoordinatorDelegate?

    private let feedBuilder: FeedBuildable
    private let myPageBuilder: MyPageBuildable

    public init(
        navigationController: UINavigationController = SwipeBackNavigationController(),
        tabBarController: MainTabBarController = MainTabBarController(),
        feedBuilder: FeedBuildable,
        myPageBuilder: MyPageBuildable,
        delegate: MainCoordinatorDelegate? = nil
    ) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        self.feedBuilder = feedBuilder
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
        let myPageViewController = myPageBuilder.makeMyPageViewController(router: self)

        tabBarController.setTabs([
            MainTabRoot(tab: .dashboard, viewController: feedViewController),
            MainTabRoot(tab: .myPage, viewController: myPageViewController)
        ], animated: false)

        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
