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
    
    let dimmedControl = UIControl()
    let floatingActionButtonOverlayView = UIView()
    let expandedButtonStackView = UIStackView()
    
    let exerciseRecordLabel = MUILabel(
        text: FeedRecordType.exercise.title,
        style: .b3,
        color: .systemWhite
    )
    
    let mealRecordLabel = MUILabel(
        text: FeedRecordType.meal.title,
        style: .b3,
        color: .systemWhite
    )
    
    let exerciseRecordButton = CircleImageButton(
        backgroundColor: .systemWhite,
        icon: .icExercise,
        iconTintColor: .gray10
    )
    
    let mealRecordButton = CircleImageButton(
        backgroundColor: .systemWhite,
        icon: .icCook,
        iconTintColor: .gray10
    )
    
    let expandedFloatingActionButton = CircleImageButton(
        backgroundColor: .gray10,
        icon: .icEdit,
        iconTintColor: .systemWhite
    )

    let floatingActionButton = CircleImageButton(
        backgroundColor: .gray10,
        icon: .icEdit,
        iconTintColor: .systemWhite
    )

    public init(reactor: FeedReactor) {
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
        reactor?.action.onNext(.viewDidLoad)
    }
    
    public func bind(reactor: FeedReactor) {
        floatingActionButton.rx.tap
            .map { FeedReactor.Action.didTapFloatingActionButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
                
        expandedFloatingActionButton.rx.tap
            .map { FeedReactor.Action.didTapFloatingActionButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        exerciseRecordButton.rx.tap
            .map { FeedReactor.Action.didTapRecordButton(.exercise) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mealRecordButton.rx.tap
            .map { FeedReactor.Action.didTapRecordButton(.meal) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dimmedControl.rx.controlEvent(.touchUpInside)
            .map { FeedReactor.Action.didTapDimmedOverlay }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.isFloatingActionButtonExpanded)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isExpanded in
                owner.setFloatingActionButtonOverlayVisible(isExpanded)
            }
            .disposed(by: disposeBag)
    }
}

private extension FeedViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        dimmedControl.backgroundColor = .systemBlack.withAlphaComponent(0.6)
        
        expandedButtonStackView.axis = .vertical
        expandedButtonStackView.alignment = .trailing
        expandedButtonStackView.spacing = 10
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
    }
}
