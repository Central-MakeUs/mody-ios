//
//  MainContainerViewController.swift
//  Main
//
//  Created by 김동준 on 7/5/26
//

import UIKit
import SnapKit
import DesignSystem
import ModyLogger
import ReactorKit
import RxCocoa
import RxSwift

final class MainContainerViewController: UIViewController, View {
    var disposeBag = DisposeBag()

    var onGroupParticipateTap: (() -> Void)?
    var onGroupCreateTap: (() -> Void)?
    var onAlarmTap: (() -> Void)?
    var currentOverlayViewController: UIViewController?

    private let navigationBar = MainNavigationBar()
    private let contentContainerView = UIView()
    private let customTabBarView: CustomTabBarView
    private let mainTabBarController: MainTabBarController
    private let tabs: [MainTab]
    private var customTabBarHeightConstraint: Constraint?

    init(
        tabBarController: MainTabBarController,
        tabs: [MainTab],
        reactor: MainReactor
    ) {
        self.mainTabBarController = tabBarController
        self.customTabBarView = CustomTabBarView(tabs: tabs)
        self.tabs = tabs
        defer { self.reactor = reactor }
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.viewWillAppear)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        customTabBarHeightConstraint?.update(offset: MainTabBarConstants.height + view.safeAreaInsets.bottom)
    }

    func bind(reactor: MainReactor) {
        reactor.state
            .observe(on: MainScheduler.instance)
            .map(\.hasUnreadNotification)
            .distinctUntilChanged()
            .bind(with: self) { owner, hasUnreadNotification in
                owner.navigationBar.setNotificationBadgeVisible(hasUnreadNotification)
            }
            .disposed(by: disposeBag)
    }

    func selectTab(_ tab: MainTab) {
        guard let index = tabs.firstIndex(of: tab) else { return }

        mainTabBarController.selectTab(index)
        customTabBarView.updateSelection(index: index)
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
        navigationBar.onAlarmTap = { [weak self] in
            self?.onAlarmTap?()
        }

        customTabBarView.onSelect = { [weak self] index in
            guard let self, tabs.indices.contains(index) else { return }

            selectTab(tabs[index])
        }
    }
}
