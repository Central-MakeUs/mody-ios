//
//  FeedViewController.swift
//  Feed
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import FeedInterface
import ReactorKit
import DesignSystem
import SnapKit
import RxCocoa

public final class FeedViewController: UIViewController, View {
    public var disposeBag = DisposeBag()
    private weak var router: FeedRouter?

    public init(
        router: FeedRouter,
        reactor: FeedReactor
    ) {
        self.router = router
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let floatingActionButton = CircleImageButton(
        backgroundColor: .gray10,
        icon: .icEdit,
        iconTintColor: .systemWhite
    )

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
        reactor?.action.onNext(.viewDidLoad)
    }
    
    public func bind(reactor: FeedReactor) {
        floatingActionButton.rx.tap
            .map { FeedReactor.Action.floatingActionButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

private extension FeedViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func setupLayout() {
        configureTempLayout()
        configureFloatingActionButtonLayout()
    }    
    
    func configureFloatingActionButtonLayout() {
        view.addSubview(floatingActionButton)
        
        floatingActionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-12)
            $0.size.equalTo(56)
        }
    }
}

private extension FeedViewController {
    func configureTempLayout() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Hello, FeedViewController~"
        label.textAlignment = .center

        let button = UIButton(type: .system)
        button.setTitle("Temp 으로 가기", for: .normal)
        button.addTarget(self, action: #selector(tempButtonTapped), for: .touchUpInside)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
        view.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    @objc
    func tempButtonTapped() {
        router?.route(from: .temp)
    }
}
