//
//  FeedViewController.swift
//  Feed
//
//  Created by 김동준 on 6/30/26
//

import UIKit
import ReactorKit
import DesignSystem
import SnapKit
import RxCocoa

public final class FeedViewController: UIViewController, View {
    public var disposeBag = DisposeBag()

    private let groupHeaderView = UIView()
    private let groupButton = FeedGroupButton()
    private let weekCalendarView = FeedWeekCalendarView()

    let dimmedControl = UIControl()
    let floatingActionButtonOverlayView = UIView()
    let expandedButtonStackView = UIStackView()
    
    let exerciseRecordLabel = MUILabel(
        text: "운동 기록",
        style: .b3,
        color: .systemWhite
    )
    
    let mealRecordLabel = MUILabel(
        text: "식사 기록",
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
            .map { FeedReactor.Action.didTapExerciseRecordButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mealRecordButton.rx.tap
            .map { FeedReactor.Action.didTapMealRecordButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dimmedControl.rx.controlEvent(.touchUpInside)
            .map { FeedReactor.Action.didTapDimmedOverlay }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        groupButton.rx.tap
            .withLatestFrom(reactor.state)
            .compactMap { FeedGroupMenuSheetViewState(state: $0) }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, viewState in
                owner.presentGroupMenuSheet(
                    groupList: viewState.groupList,
                    selectedGroup: viewState.selectedGroup,
                    onGroupSelect: { group in
                        reactor.action.onNext(.didSelectGroup(group))
                    },
                    onAddGroupTap: {
                        reactor.action.onNext(.didTapAddGroup)
                    }
                )
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.isFloatingActionButtonExpanded)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isExpanded in
                owner.setFloatingActionButtonOverlayVisible(isExpanded)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { state in
                FeedGroupHeaderViewState(
                    isLoading: state.isFetchGroupLoading,
                    groupName: state.selectedGroup?.name
                )
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, viewState in
                owner.groupButton.configure(
                    title: viewState.groupName,
                    isLoading: viewState.isLoading
                )
            }
            .disposed(by: disposeBag)

        bindWeekCalendar(reactor)
    }
}

private extension FeedViewController {
    func bindWeekCalendar(_ reactor: FeedReactor) {
        weekCalendarView.onPreviousWeekTap = { [weak reactor] in
            reactor?.action.onNext(.didTapPreviousWeek)
        }

        weekCalendarView.onNextWeekTap = { [weak reactor] in
            reactor?.action.onNext(.didTapNextWeek)
        }

        weekCalendarView.onDateTap = { [weak reactor] model in
            reactor?.action.onNext(.didTapCalendarDate(model))
        }

        reactor.state
            .map(\.weekCalendarViewState)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, viewState in
                owner.weekCalendarView.configure(
                    title: viewState.calendarTitle,
                    dates: viewState.calendarDates,
                    canMovePrevious: viewState.canMovePreviousWeek,
                    canMoveNext: viewState.canMoveNextWeek,
                    todayDate: viewState.todayDate,
                    selectedDate: viewState.selectedDate
                )
            }
            .disposed(by: disposeBag)
    }
}

private extension FeedViewController {
    func setupUI() {
        view.backgroundColor = .systemWhite
        groupHeaderView.backgroundColor = .systemWhite
        dimmedControl.backgroundColor = .systemBlack.withAlphaComponent(0.6)
        
        expandedButtonStackView.axis = .vertical
        expandedButtonStackView.alignment = .trailing
        expandedButtonStackView.spacing = 10
    }
    
    func setupLayout() {
        configureGroupHeaderLayout()
        configureFloatingActionButtonLayout()
        configureWeekCalendarLayout()
    }

    func configureGroupHeaderLayout() {
        view.addSubview(groupHeaderView)
        groupHeaderView.addSubview(groupButton)

        groupHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        groupButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureFloatingActionButtonLayout() {
        view.addSubview(floatingActionButton)
        
        floatingActionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-12)
            $0.size.equalTo(56)
        }
    }

    func configureWeekCalendarLayout() {
        view.addSubview(weekCalendarView)

        weekCalendarView.snp.makeConstraints {
            $0.top.equalTo(groupHeaderView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
