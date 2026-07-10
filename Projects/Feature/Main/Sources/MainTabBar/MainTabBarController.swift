//
//  MainTabBarController.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit

public final class MainTabBarController: UITabBarController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        hideSystemTabBar()
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
    }

    func selectTab(_ index: Int) {
        selectedIndex = index
    }
}

private extension MainTabBarController {
    func hideSystemTabBar() {
        tabBar.isHidden = true
    }
}
