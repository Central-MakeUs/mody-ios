//
//  MainContainerViewController.swift
//  Main
//
//  Created by 김동준 on 7/5/26
//

import UIKit
import SnapKit
import DesignSystem

final class MainContainerViewController: UIViewController {
    var onUsersTap: (() -> Void)?
    var onAlarmTap: (() -> Void)?
    weak var currentOverlayView: UIView?

    private let navigationBar = MainNavigationBar()
    private let mainTabBarController: MainTabBarController

    init(tabBarController: MainTabBarController) {
        self.mainTabBarController = tabBarController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupChild()
        bind()
    }
}

private extension MainContainerViewController {
    func setupUI() {
        view.backgroundColor = .systemWhite
    }

    func setupLayout() {
        view.addSubview(navigationBar)

        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
    }

    func setupChild() {
        addChild(mainTabBarController)
        view.addSubview(mainTabBarController.view)

        mainTabBarController.view.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        mainTabBarController.didMove(toParent: self)
    }

    func bind() {
        navigationBar.onUsersTap = { [weak self] in
            self?.onUsersTap?()
        }

        navigationBar.onAlarmTap = { [weak self] in
            self?.onAlarmTap?()
        }
    }
}
