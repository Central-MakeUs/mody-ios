//
//  CustomTabBar+.swift
//  Main
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import SnapKit

extension MainTabBarController {
    func configureCustomTabBar(tabs: [MainTab]) {
        customTabBarView?.removeFromSuperview()

        let customTabBarView = CustomTabBarView(tabs: tabs)
        customTabBarView.onSelect = { [weak self] index in
            self?.selectTab(index)
        }

        view.addSubview(customTabBarView)
        customTabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            customTabBarHeightConstraint = $0.height
                .equalTo(MainTabBarConstants.height + view.safeAreaInsets.bottom)
                .constraint
        }

        self.customTabBarView = customTabBarView

        updateCustomTabBarHeight()
        customTabBarView.updateSelection(index: selectedIndex)
    }

    func selectTab(_ index: Int) {
        selectedIndex = index
        customTabBarView?.updateSelection(index: index)
    }

    func updateCustomTabBarHeight() {
        customTabBarHeightConstraint?.update(offset: MainTabBarConstants.height + view.safeAreaInsets.bottom)
    }
}
