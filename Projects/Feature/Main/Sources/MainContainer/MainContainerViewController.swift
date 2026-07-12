//
//  MainContainerViewController.swift
//  Main
//
//  Created by 김동준 on 7/5/26
//

import UIKit
import SwiftUI
import SnapKit
import DesignSystem
import ModyLogger

final class MainContainerViewController: UIViewController {
    var onSheetGroupParticipateTap: (() -> Void)?
    var onSheetGroupCreateTap: (() -> Void)?
    var onAlarmTap: (() -> Void)?
    weak var currentOverlayView: UIView?

    private let navigationBar = MainNavigationBar()
    private let contentContainerView = UIView()
    private let customTabBarView: CustomTabBarView
    private let mainTabBarController: MainTabBarController
    private var customTabBarHeightConstraint: Constraint?

    init(
        tabBarController: MainTabBarController,
        tabs: [MainTab]
    ) {
        self.mainTabBarController = tabBarController
        self.customTabBarView = CustomTabBarView(tabs: tabs)
        super.init(nibName: nil, bundle: nil)
        ModyLogger.debug("⭕ MainContainerViewController init!")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        ModyLogger.debug("❎ MainContainerViewController deinit!")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupChild()
        bind()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        customTabBarHeightConstraint?.update(offset: MainTabBarConstants.height + view.safeAreaInsets.bottom)
    }
}

private extension MainContainerViewController {
    func setupUI() {
        view.backgroundColor = .systemWhite
    }

    func setupLayout() {
        view.addSubview(navigationBar)
        view.addSubview(contentContainerView)
        view.addSubview(customTabBarView)

        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(customTabBarView.snp.top)
        }

        customTabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            customTabBarHeightConstraint = $0.height
                .equalTo(MainTabBarConstants.height + view.safeAreaInsets.bottom)
                .constraint
        }
    }

    func setupChild() {
        addChild(mainTabBarController)
        contentContainerView.addSubview(mainTabBarController.view)

        mainTabBarController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        mainTabBarController.didMove(toParent: self)
    }

    func bind() {
        navigationBar.onUsersTap = { [weak self] in
            self?.presentGroupMenuSheet()
        }

        navigationBar.onAlarmTap = { [weak self] in
            self?.onAlarmTap?()
        }

        customTabBarView.onSelect = { [weak self] index in
            self?.mainTabBarController.selectTab(index)
            self?.customTabBarView.updateSelection(index: index)
        }
    }
}
