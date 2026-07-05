//
//  MainTabBarController.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SnapKit

public final class MainTabBarController: UITabBarController {
    var customTabBarView: CustomTabBarView?
    var customTabBarHeightConstraint: Constraint?

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        hideSystemTabBar()
    }

    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateCustomTabBarHeight()
    }

    deinit {
        print("❎ MainTabBarController deinit!")
    }
}

public extension MainTabBarController {
    func setTabs(
        tabs: [MainTab],
        viewControllers: [UIViewController],
        animated: Bool
    ) {
        setViewControllers(viewControllers, animated: animated)
        configureCustomTabBar(tabs: tabs)
    }
}

private extension MainTabBarController {
    func hideSystemTabBar() {
        tabBar.isHidden = true
    }
}
