//
//  FeedDemoMainContainerViewController.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import DesignSystem
import UIKit

final class FeedDemoMainContainerViewController: UIViewController {
    private let feedViewController: UIViewController
    private let navigationBar = MainNavigationBar()
    private let contentContainerView = UIView()
    private let tabBarPlaceholderView = UIView()
    private let tabBarDividerView = UIView()
    private let tabBarStackView = UIStackView()
    private var tabBarHeightConstraint: NSLayoutConstraint?

    init(feedViewController: UIViewController) {
        self.feedViewController = feedViewController
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
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        tabBarHeightConstraint?.constant = 48 + view.safeAreaInsets.bottom
    }
}

private extension FeedDemoMainContainerViewController {
    func setupUI() {
        view.backgroundColor = .systemWhite
        contentContainerView.backgroundColor = .systemWhite

        tabBarPlaceholderView.backgroundColor = .systemWhite
        tabBarDividerView.backgroundColor = .gray2

        tabBarStackView.axis = .horizontal
        tabBarStackView.alignment = .fill
        tabBarStackView.distribution = .fillEqually

        ["피드", "챌린지", "마이"].enumerated().forEach { index, title in
            tabBarStackView.addArrangedSubview(
                makeTabItem(title: title, isSelected: index == 0)
            )
        }
    }

    func setupLayout() {
        [navigationBar, contentContainerView, tabBarPlaceholderView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [tabBarDividerView, tabBarStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            tabBarPlaceholderView.addSubview($0)
        }

        let tabBarHeightConstraint = tabBarPlaceholderView.heightAnchor.constraint(
            equalToConstant: 48 + view.safeAreaInsets.bottom
        )
        self.tabBarHeightConstraint = tabBarHeightConstraint

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentContainerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: tabBarPlaceholderView.topAnchor),

            tabBarPlaceholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarPlaceholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarPlaceholderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarHeightConstraint,

            tabBarDividerView.topAnchor.constraint(equalTo: tabBarPlaceholderView.topAnchor),
            tabBarDividerView.leadingAnchor.constraint(equalTo: tabBarPlaceholderView.leadingAnchor),
            tabBarDividerView.trailingAnchor.constraint(equalTo: tabBarPlaceholderView.trailingAnchor),
            tabBarDividerView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            tabBarStackView.topAnchor.constraint(equalTo: tabBarDividerView.bottomAnchor),
            tabBarStackView.leadingAnchor.constraint(equalTo: tabBarPlaceholderView.leadingAnchor),
            tabBarStackView.trailingAnchor.constraint(equalTo: tabBarPlaceholderView.trailingAnchor),
            tabBarStackView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    func setupChild() {
        addChild(feedViewController)
        feedViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(feedViewController.view)

        NSLayoutConstraint.activate([
            feedViewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            feedViewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            feedViewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            feedViewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])

        feedViewController.didMove(toParent: self)
    }

    func makeTabItem(title: String, isSelected: Bool) -> UIView {
        let label = UILabel()
        label.text = title
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: isSelected ? .semibold : .regular)
        label.textColor = isSelected ? .gray10 : .gray5
        return label
    }
}
