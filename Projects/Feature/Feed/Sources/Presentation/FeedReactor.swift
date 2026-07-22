//
//  FeedReactor.swift
//  Feed
//
//  Created by 김동준 on 7/11/26
//

import Foundation
import CoreAuthInterface
import CommonDomain
import FeedInterface
import ModyGroupInterface
import ReactorKit

public final class FeedReactor: Reactor {
    private let authUseCase: AuthUseCaseProtocol
    private let groupUseCase: GroupUseCaseProtocol
    private let feedUseCase: FeedUseCase
    private weak var router: FeedRouter?
    public let initialState: State
    private let baseDate: Date
    private let calendar: Calendar
    private let feedPageSize = 5

    public struct State {
        var isFloatingActionButtonExpanded = false
        var groups: [GroupModel] = []
        var selectedGroup: GroupModel?
        var isFetchGroupLoading = false
        var myMemberId: Int?

        var feedRecords: [FeedRecord] = []
        var isInitialFeedLoading = false
        var isNextPageLoading = false
        var nextFeedCursor: Int?
        var hasNextFeedPage = false

        var weekCalendarViewState: FeedWeekCalendarViewState
        var weekOffset = 0
    }
    
    public enum Mutation {
        case setFloatingActionButtonExpanded(Bool)
        case setGroups([GroupModel])
        case setSelectedGroup(GroupModel)
        case setFetchGroupLoading(Bool)
        case setMyMemberId(Int?)
        case setInitialFeedLoading(Bool)
        case setNextPageLoading(Bool)
        case setFeedPage(FeedRecordPage)
        case appendFeedPage(FeedRecordPage)
        case resetFeedRecords

        case setWeekCalendar(
            offset: Int,
            title: String,
            dates: [FeedWeekCalendarModel]
        )
        case setSelectedCalendarDate(String)
    }
    
    public enum Action {
        case viewDidLoad
        case didTapDimmedOverlay
        case didTapFloatingActionButton
        case didTapExerciseRecordButton
        case didTapMealRecordButton
        case didTapAddGroup
        case didSelectGroup(GroupModel)

        case didTapPreviousWeek
        case didTapNextWeek
        case didTapCalendarDate(FeedWeekCalendarModel)
        case didReachFeedListBottom
        
        case didTapRecordButton(FeedRecordType)
    }
    
    public init(
        authUseCase: AuthUseCaseProtocol,
        groupUseCase: GroupUseCaseProtocol,
        feedUseCase: FeedUseCase,
        router: FeedRouter
    ) {
        self.authUseCase = authUseCase
        self.groupUseCase = groupUseCase
        self.feedUseCase = feedUseCase
        self.router = router
        let calendar = Date.koreanCalendar
        let baseDate = Date().startOfDay(calendar: calendar)
        let weekInfo = FeedWeekCalendarCalculator.calculateWeekInfoFromBaseDate(
            baseDate,
            calendar: calendar
        )
        let todayDate = baseDate.toString()

        self.calendar = calendar
        self.baseDate = baseDate
        self.initialState = State(
            weekCalendarViewState: FeedWeekCalendarViewState(
                calendarTitle: weekInfo.title,
                calendarDates: FeedWeekCalendarCalculator.makeModels(
                    containing: baseDate,
                    calendar: calendar
                ),
                canMovePreviousWeek: true,
                canMoveNextWeek: false,
                todayDate: todayDate,
                selectedDate: todayDate
            )
        )
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return fetchInitialFeed()
        case .didTapDimmedOverlay:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapFloatingActionButton:
            return .just(.setFloatingActionButtonExpanded(!currentState.isFloatingActionButtonExpanded))
        case .didTapExerciseRecordButton:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapMealRecordButton:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapAddGroup:
            Task { @MainActor [weak router] in
                router?.route(from: .addGroup)
            }
            return .empty()
        case let .didSelectGroup(group):
            guard currentState.groups.contains(where: { $0.groupId == group.groupId }) else {
                return .empty()
            }
            return .concat([
                .just(.setSelectedGroup(group)),
                fetchFirstFeedPage(
                    groupId: group.groupId,
                    date: currentState.weekCalendarViewState.selectedDate
                )
            ])
        case .didTapPreviousWeek:
            return makeCalendarMutation(offset: currentState.weekOffset - 1)
        case .didTapNextWeek:
            guard currentState.weekCalendarViewState.canMoveNextWeek else { return .empty() }
            return makeCalendarMutation(offset: currentState.weekOffset + 1)
        case let .didTapCalendarDate(model):
            guard FeedWeekCalendarCalculator.isSelectable(
                date: model.date,
                latestSelectableDate: currentState.weekCalendarViewState.todayDate,
                calendar: calendar
            ) else {
                return .empty()
            }

            return .concat([
                .just(.setSelectedCalendarDate(model.date)),
                fetchFirstFeedPage(
                    groupId: currentState.selectedGroup?.groupId,
                    date: model.date
                )
            ])
        case .didReachFeedListBottom:
            guard !currentState.isInitialFeedLoading,
                  !currentState.isNextPageLoading,
                  currentState.hasNextFeedPage,
                  let selectedGroup = currentState.selectedGroup,
                  let nextCursor = currentState.nextFeedCursor else {
                return .empty()
            }

            return fetchNextFeedPage(
                groupId: selectedGroup.groupId,
                date: currentState.weekCalendarViewState.selectedDate,
                cursor: nextCursor
            )
        case .didTapRecordButton(let recordType):
            return .concat([
                .just(.setFloatingActionButtonExpanded(false)),
                routeToRecord(recordType)
            ])
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setFloatingActionButtonExpanded(let isExpanded):
            newState.isFloatingActionButtonExpanded = isExpanded
        case .setGroups(let groups):
            newState.groups = groups
            if newState.selectedGroup == nil, groups.count > 0 {
                newState.selectedGroup = groups.first
            }
        case .setSelectedGroup(let group):
            newState.selectedGroup = group
        case .setFetchGroupLoading(let isLoading):
            newState.isFetchGroupLoading = isLoading
        case .setMyMemberId(let memberId):
            newState.myMemberId = memberId
        case .setInitialFeedLoading(let isLoading):
            newState.isInitialFeedLoading = isLoading
        case .setNextPageLoading(let isLoading):
            newState.isNextPageLoading = isLoading
        case .setFeedPage(let page):
            newState.feedRecords = page.records
            newState.nextFeedCursor = page.nextCursor
            newState.hasNextFeedPage = page.hasNext
        case .appendFeedPage(let page):
            newState.feedRecords.append(contentsOf: page.records)
            newState.nextFeedCursor = page.nextCursor
            newState.hasNextFeedPage = page.hasNext
        case .resetFeedRecords:
            newState.feedRecords = []
            newState.nextFeedCursor = nil
            newState.hasNextFeedPage = false
        case let .setWeekCalendar(offset, title, dates):
            newState.weekOffset = offset
            newState.weekCalendarViewState.calendarTitle = title
            newState.weekCalendarViewState.calendarDates = dates
            newState.weekCalendarViewState.canMovePreviousWeek = true
            newState.weekCalendarViewState.canMoveNextWeek = offset < 0
        case let .setSelectedCalendarDate(date):
            newState.weekCalendarViewState.selectedDate = date
        }
        
        return newState
    }
}

private extension FeedReactor {
    func fetchInitialFeed() -> Observable<Mutation> {
        let selectedDate = currentState.weekCalendarViewState.selectedDate

        return Observable<Mutation>.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                observer.onNext(.setFetchGroupLoading(true))
                observer.onNext(.setInitialFeedLoading(true))

                try await Task.sleep(for: .seconds(5))
                do {
                    async let groupsResponse = self.groupUseCase.getGroups()
                    async let userInfoResponse = self.authUseCase.getUserInfo(needUpdateKeyChain: false)
                    let (groups, userInfo) = try await (groupsResponse, userInfoResponse)
                    observer.onNext(.setGroups(groups))
                    observer.onNext(.setMyMemberId(userInfo.memberId))

                    if let selectedGroup = groups.first {
                        let page = try await self.feedUseCase.fetchFeedRecords(
                            groupId: selectedGroup.groupId,
                            date: selectedDate,
                            cursor: nil,
                            size: self.feedPageSize
                        )
                        observer.onNext(.setFeedPage(page))
                    } else {
                        observer.onNext(.resetFeedRecords)
                    }
                } catch {
                    observer.onNext(.resetFeedRecords)
                }

                observer.onNext(.setInitialFeedLoading(false))
                observer.onNext(.setFetchGroupLoading(false))
                observer.onCompleted()
            }

            return Disposables.create { task.cancel() }
        }
    }

    func fetchFirstFeedPage(
        groupId: Int?,
        date: String
    ) -> Observable<Mutation> {
        guard let groupId else {
            return .just(.resetFeedRecords)
        }

        return Observable<Mutation>.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                observer.onNext(.setInitialFeedLoading(true))

                do {
                    let page = try await self.feedUseCase.fetchFeedRecords(
                        groupId: groupId,
                        date: date,
                        cursor: nil,
                        size: self.feedPageSize
                    )
                    observer.onNext(.setFeedPage(page))
                } catch {
                    observer.onNext(.resetFeedRecords)
                }

                observer.onNext(.setInitialFeedLoading(false))
                observer.onCompleted()
            }

            return Disposables.create { task.cancel() }
        }
    }

    func fetchNextFeedPage(
        groupId: Int,
        date: String,
        cursor: Int
    ) -> Observable<Mutation> {
        Observable<Mutation>.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                observer.onNext(.setNextPageLoading(true))

                do {
                    let page = try await self.feedUseCase.fetchFeedRecords(
                        groupId: groupId,
                        date: date,
                        cursor: cursor,
                        size: self.feedPageSize
                    )
                    observer.onNext(.appendFeedPage(page))
                } catch { }

                observer.onNext(.setNextPageLoading(false))
                observer.onCompleted()
            }

            return Disposables.create { task.cancel() }
        }
    }
}

private extension FeedReactor {
    func makeCalendarMutation(offset: Int) -> Observable<Mutation> {
        guard offset <= 0,
              let targetDate = calendar.date(
                byAdding: .weekOfYear,
                value: offset,
                to: baseDate
              ) else {
            return .empty()
        }

        let weekInfo = FeedWeekCalendarCalculator.calculateWeekInfoFromBaseDate(
            targetDate,
            calendar: calendar
        )
        let models = FeedWeekCalendarCalculator.makeModels(
            containing: targetDate,
            calendar: calendar
        )

        return .just(.setWeekCalendar(
            offset: offset,
            title: weekInfo.title,
            dates: models
        ))
    }
    
    func routeToRecord(_ recordType: FeedRecordType) -> Observable<Mutation> {
        return .deferred { [weak router] in
            Task { @MainActor in
                router?.route(from: .routeToRecord(recordType))
            }
            return .empty()
        }
    }
}
