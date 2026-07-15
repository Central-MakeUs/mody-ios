//
//  FeedRecordViewController.swift
//  Feed
//
//  Created by 김동준 on 7/12/26.
//

import UIKit
import SwiftUI
import FeedInterface
import ReactorKit
import DesignSystem
import SnapKit

public final class FeedRecordViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()

    private let navigationBarContainerView = UIView()
    private let contentLabel = MUILabel(
        style: .b3,
        color: .gray10
    )

    public init(reactor: FeedRecordReactor) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
        configureNavigationBar()
    }

    public func bind(reactor: FeedRecordReactor) {
        reactor.state
            .map(\.recordType.title)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, title in
                owner.contentLabel.text = "\(title) 화면"
            }
            .disposed(by: disposeBag)
    }
}

private extension FeedRecordViewController {
    func setupUI() {
        view.backgroundColor = .systemWhite
        contentLabel.textAlignment = .center
    }

    func setupLayout() {
        view.addSubview(navigationBarContainerView)
        view.addSubview(contentLabel)

        navigationBarContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        contentLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func configureNavigationBar() {
        guard let recordType = reactor?.currentState.recordType else { return }

        let navigationBar = MNavigationBar(
            title: recordType.title,
            onBackTap: { [weak self] in
                self?.reactor?.action.onNext(.didTapBackButton)
            }
        )
        let hostingController = UIHostingController(rootView: navigationBar)

        setupNavigationBarLayout(hostingController)
        hostingController.didMove(toParent: self)
    }

    func setupNavigationBarLayout(_ hostingController: UIHostingController<MNavigationBar>) {
        addChild(hostingController)
        navigationBarContainerView.addSubview(hostingController.view)

        hostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
