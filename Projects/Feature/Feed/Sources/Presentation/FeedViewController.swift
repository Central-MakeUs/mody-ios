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
import FeedInterface

public final class FeedViewController: UIViewController, View, FeedInputHandler {
    public var disposeBag = DisposeBag()

    private let groupHeaderView = UIView()
    private let groupButton = FeedGroupButton()
    private let weekCalendarView = FeedWeekCalendarView()
    private let feedEmptyView = FeedEmptyView()
    private let feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 16, left: 24, bottom: 36, right: 24)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemWhite
        collectionView.showsVerticalScrollIndicator = true
        return collectionView
    }()
    var feedListViewState = FeedListViewState(
        records: [],
        isInitialLoading: false,
        isNextPageLoading: false,
        isEmpty: false
    )

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
            .observe(on: MainScheduler.instance)
            .map(\.isFloatingActionButtonExpanded)
            .distinctUntilChanged()
            .bind(with: self) { owner, isExpanded in
                owner.setFloatingActionButtonOverlayVisible(isExpanded)
            }
            .disposed(by: disposeBag)

        reactor.state
            .observe(on: MainScheduler.instance)
            .map { state in
                FeedGroupHeaderViewState(
                    isLoading: state.isFetchGroupLoading,
                    groupName: state.selectedGroup?.name
                )
            }
            .distinctUntilChanged()
            .bind(with: self) { owner, viewState in
                owner.groupButton.configure(
                    title: viewState.groupName,
                    isLoading: viewState.isLoading
                )
            }
            .disposed(by: disposeBag)

        bindWeekCalendar(reactor)
        bindFeedList(reactor)
    }

    public func handle(input: FeedInput) {
        reactor?.action.onNext(.input(input))
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
            .observe(on: MainScheduler.instance)
            .map(\.weekCalendarViewState)
            .distinctUntilChanged()
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
    func bindFeedList(_ reactor: FeedReactor) {
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { state in
                FeedListViewState(
                    records: state.feedRecords.map {
                        FeedRecordCardViewState(
                            record: $0,
                            myMemberId: state.myMemberId
                        )
                    },
                    isInitialLoading: state.isInitialFeedLoading,
                    isNextPageLoading: state.isNextPageLoading,
                    isEmpty: !state.isInitialFeedLoading && state.feedRecords.isEmpty
                )
            }
            .distinctUntilChanged()
            .bind(with: self) { owner, viewState in
                owner.feedListViewState = viewState
                owner.feedCollectionView.isHidden = viewState.isEmpty
                owner.feedEmptyView.isHidden = !viewState.isEmpty
                owner.feedCollectionView.reloadData()
                owner.feedCollectionView.collectionViewLayout.invalidateLayout()
            }
            .disposed(by: disposeBag)

        feedCollectionView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .filter { [weak self] offset in
                guard let self else { return false }
                let visibleBottom = offset.y + self.feedCollectionView.bounds.height
                let triggerOffset = self.feedCollectionView.contentSize.height - 120
                return self.feedCollectionView.contentSize.height > 0 && visibleBottom >= triggerOffset
            }
            .map { _ in FeedReactor.Action.didReachFeedListBottom }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        feedCollectionView.rx.contentOffset
            .map { $0.y > 0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isScrolled in
                owner.weekCalendarView.setShadowVisible(isScrolled)
            }
            .disposed(by: disposeBag)
    }
}

private extension FeedViewController {
    func setupUI() {
        view.backgroundColor = .systemWhite
        groupHeaderView.backgroundColor = .systemWhite
        dimmedControl.backgroundColor = .systemBlack.withAlphaComponent(0.6)
        feedEmptyView.isHidden = true
        feedCollectionView.dataSource = self
        feedCollectionView.delegate = self
        feedCollectionView.register(
            FeedRecordCardCell.self,
            forCellWithReuseIdentifier: FeedRecordCardCell.reuseIdentifier
        )
        feedCollectionView.register(
            FeedRecordSkeletonCell.self,
            forCellWithReuseIdentifier: FeedRecordSkeletonCell.reuseIdentifier
        )
        feedCollectionView.register(
            FeedLoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: FeedLoadingFooterView.reuseIdentifier
        )
        
        expandedButtonStackView.axis = .vertical
        expandedButtonStackView.alignment = .trailing
        expandedButtonStackView.spacing = 10
    }
    
    func setupLayout() {
        configureGroupHeaderLayout()
        configureWeekCalendarLayout()
        configureFeedListLayout()
        configureFloatingActionButtonLayout()
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

    func configureFeedListLayout() {
        view.addSubview(feedCollectionView)
        view.addSubview(feedEmptyView)
        view.bringSubviewToFront(weekCalendarView)

        feedCollectionView.snp.makeConstraints {
            $0.top.equalTo(weekCalendarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        feedEmptyView.snp.makeConstraints {
            $0.top.equalTo(weekCalendarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
