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
    private let output: @MainActor (FeedOutput) -> Void

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

        var feedPage = FeedRecordPage(
            records: [],
            nextCursor: nil,
            hasNext: false
        )
        var isInitialFeedLoading = false
        var isNextPageLoading = false
        var isReportLoading = false
        var feedRecords: [FeedRecord] { feedPage.records }
        var nextFeedCursor: Int? { feedPage.nextCursor }
        var hasNextFeedPage: Bool { feedPage.hasNext }

        var weekCalendarViewState: FeedWeekCalendarViewState
        var weekOffset = 0
    }
    
    public enum Mutation {
        case setFloatingActionButtonExpanded(Bool)
        case setGroups([GroupModel], selectedGroup: GroupModel?)
        case setFetchGroupLoading(Bool)
        case setMyMemberId(Int?)
        case setInitialFeedLoading(Bool)
        case setNextPageLoading(Bool)
        case setReportLoading(Bool)
        case setFeedPage(FeedRecordPage)
        case resetFeedRecords

        case setWeekCalendar(
            offset: Int,
            title: String,
            dates: [FeedWeekCalendarModel]
        )
        case markCalendarDateHasRecord(String)
        case setSelectedCalendarDate(String)
    }
    
    public enum Action {
        case viewDidLoad
        case input(FeedInput)
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
        case didTapRecordMenu(FeedRecordMenu, recordId: Int)
        
        case didTapRecordButton(FeedRecordType)
    }
    
    public init(
        authUseCase: AuthUseCaseProtocol,
        groupUseCase: GroupUseCaseProtocol,
        feedUseCase: FeedUseCase,
        router: FeedRouter,
        output: @escaping @MainActor (FeedOutput) -> Void
    ) {
        self.authUseCase = authUseCase
        self.groupUseCase = groupUseCase
        self.feedUseCase = feedUseCase
        self.router = router
        self.output = output
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
            return fetchInitialContent()
        case .input(.refreshGroups):
            return fetchGroupsWithLoading()
        case let .input(.reportConfirmed(recordId)):
            guard !currentState.isReportLoading else { return .empty() }
            guard let groupId = currentState.selectedGroup?.groupId else {
                return sendOutput(.reportFailed(.invalidResponse))
            }
            return reportRecord(groupId: groupId, recordId: recordId)
        case .didTapDimmedOverlay,
             .didTapExerciseRecordButton,
             .didTapMealRecordButton:
            return .just(.setFloatingActionButtonExpanded(false))
        case .didTapFloatingActionButton:
            return .just(.setFloatingActionButtonExpanded(!currentState.isFloatingActionButtonExpanded))
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
                setGroup(group, in: currentState.groups),
                fetchSelectedGroupContent()
            ])
        case .didTapPreviousWeek:
            return makeCalendarMutationWithActivityFetch(offset: currentState.weekOffset - 1)
        case .didTapNextWeek:
            guard currentState.weekCalendarViewState.canMoveNextWeek else { return .empty() }
            return makeCalendarMutationWithActivityFetch(offset: currentState.weekOffset + 1)
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
                  currentState.nextFeedCursor != nil else {
                return .empty()
            }

            return fetchNextFeedPage(
                groupId: selectedGroup.groupId,
                date: currentState.weekCalendarViewState.selectedDate
            )
        case let .didTapRecordMenu(.report, recordId):
            return sendOutput(.reportConfirmationRequested(recordId: recordId))
        case .didTapRecordButton(let recordType):
            return .concat([
                .just(.setFloatingActionButtonExpanded(false)),
                routeToRecord(recordType)
            ])
        case .input(.recordCreated):
            guard let groupId = currentState.selectedGroup?.groupId else {
                return .empty()
            }

            return .concat([
                .just(.markCalendarDateHasRecord(
                    currentState.weekCalendarViewState.todayDate
                )),
                fetchLatestFeedPage(
                    groupId: groupId,
                    date: currentState.weekCalendarViewState.selectedDate
                )
            ])
        case .input(.profileUpdated):
            return fetchFirstFeedPage(
                groupId: currentState.selectedGroup?.groupId,
                date: currentState.weekCalendarViewState.selectedDate
            )
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setFloatingActionButtonExpanded(let isExpanded):
            newState.isFloatingActionButtonExpanded = isExpanded
        case let .setGroups(groups, selectedGroup):
            newState.groups = groups
            newState.selectedGroup = selectedGroup
        case .setFetchGroupLoading(let isLoading):
            newState.isFetchGroupLoading = isLoading
        case .setMyMemberId(let memberId):
            newState.myMemberId = memberId
        case .setInitialFeedLoading(let isLoading):
            newState.isInitialFeedLoading = isLoading
        case .setNextPageLoading(let isLoading):
            newState.isNextPageLoading = isLoading
        case .setReportLoading(let isLoading):
            newState.isReportLoading = isLoading
        case .setFeedPage(let page):
            newState.feedPage = page
        case .resetFeedRecords:
            newState.feedPage = FeedRecordPage(
                records: [],
                nextCursor: nil,
                hasNext: false
            )
        case let .setWeekCalendar(offset, title, dates):
            newState.weekOffset = offset
            newState.weekCalendarViewState.calendarTitle = title
            newState.weekCalendarViewState.calendarDates = dates
            newState.weekCalendarViewState.canMovePreviousWeek = true
            newState.weekCalendarViewState.canMoveNextWeek = offset < 0
        case let .markCalendarDateHasRecord(date):
            newState.weekCalendarViewState.calendarDates = newState
                .weekCalendarViewState
                .calendarDates
                .map { model in
                    guard model.date == date, !model.hasRecord else {
                        return model
                    }

                    return FeedWeekCalendarModel(
                        date: model.date,
                        dayOfWeek: model.dayOfWeek,
                        hasRecord: true
                    )
                }
        case let .setSelectedCalendarDate(date):
            newState.weekCalendarViewState.selectedDate = date
        }
        
        return newState
    }
}

private extension FeedReactor {
    func setGroup(
        _ selectedGroup: GroupModel?,
        in groups: [GroupModel]
    ) -> Observable<Mutation> {
        .concat([
            .just(.setGroups(groups, selectedGroup: selectedGroup)),
            sendOutput(.selectedGroupUpdated(selectedGroup))
        ])
    }

    func sendOutput(_ output: FeedOutput) -> Observable<Mutation> {
        asyncObservable { [weak self] in
            self?.output(output)
            return nil
        }
    }

    func reportRecord(
        groupId: Int,
        recordId: Int
    ) -> Observable<Mutation> {
        withLoading(
            Mutation.setReportLoading,
            operation: asyncObservable { [weak self] in
                guard let self else { return nil }

                do {
                    try await self.feedUseCase.reportRecord(
                        groupId: groupId,
                        recordId: recordId
                    )
                    self.output(.reportSucceeded)
                } catch {
                    self.output(.reportFailed(error as? NetworkError ?? .unknown))
                }

                return nil
            }
        )
    }

    func fetchInitialContent() -> Observable<Mutation> {
        withLoading(
            Mutation.setFetchGroupLoading,
            operation: .concat([
                .merge(
                    fetchGroups(),
                    fetchMyMemberId()
                ),
                fetchSelectedGroupContent()
            ])
        )
    }

    func fetchGroupsWithLoading() -> Observable<Mutation> {
        withLoading(
            Mutation.setFetchGroupLoading,
            operation: .concat([
                fetchGroups(),
                fetchSelectedGroupContent()
            ])
        )
    }
    
    func fetchSelectedGroupContent() -> Observable<Mutation> {
        .deferred { [weak self] in
            guard let self else { return .empty() }

            guard let groupId = self.currentState.selectedGroup?.groupId else {
                return .concat([
                    self.makeCalendarMutation(offset: self.currentState.weekOffset),
                    .just(.resetFeedRecords)
                ])
            }

            return self.withLoading(
                Mutation.setInitialFeedLoading,
                operation: .concat([
                    self.fetchMyMemberIdIfNeeded(),
                    .merge(
                        self.fetchActivityCalendar(
                            groupId: groupId,
                            offset: self.currentState.weekOffset
                        ),
                        self.fetchFeedPage(
                            groupId: groupId,
                            date: self.currentState.weekCalendarViewState.selectedDate
                        )
                    )
                ])
            )
        }
    }

    func fetchMyMemberIdIfNeeded() -> Observable<Mutation> {
        .deferred { [weak self] in
            guard let self,
                  self.currentState.myMemberId == nil else {
                return .empty()
            }

            return self.fetchMyMemberId()
        }
    }

    func fetchFirstFeedPage(
        groupId: Int?,
        date: String
    ) -> Observable<Mutation> {
        guard let groupId else {
            return .just(.resetFeedRecords)
        }

        return withLoading(
            Mutation.setInitialFeedLoading,
            operation: fetchFeedPage(groupId: groupId, date: date)
        )
    }

    func fetchFeedPage(
        groupId: Int,
        date: String
    ) -> Observable<Mutation> {
        asyncObservable { [weak self] in
            guard let self else { return nil }

            do {
                let page = try await self.feedUseCase.fetchFeedRecords(
                    groupId: groupId,
                    date: date,
                    cursor: nil,
                    size: self.feedPageSize
                )
                return .setFeedPage(page)
            } catch {
                return .resetFeedRecords
            }
        }
    }

    func fetchNextFeedPage(
        groupId: Int,
        date: String
    ) -> Observable<Mutation> {
        let currentPage = currentState.feedPage

        return withLoading(
            Mutation.setNextPageLoading,
            operation: asyncObservable { [weak self] in
                guard let self else { return nil }

                let page = try? await self.feedUseCase.fetchNextFeedRecords(
                    groupId: groupId,
                    date: date,
                    currentPage: currentPage,
                    size: self.feedPageSize
                )

                return page.map(Mutation.setFeedPage)
            }
        )
    }

    func fetchLatestFeedPage(
        groupId: Int,
        date: String
    ) -> Observable<Mutation> {
        let currentPage = currentState.feedPage

        return asyncObservable { [weak self] in
            guard let self else { return nil }

            let page = try? await self.feedUseCase.refreshLatestFeedRecords(
                groupId: groupId,
                date: date,
                currentPage: currentPage,
                size: self.feedPageSize
            )

            return page.map(Mutation.setFeedPage)
        }
    }
}

private extension FeedReactor {
    func makeCalendarMutationWithActivityFetch(offset: Int) -> Observable<Mutation> {
        guard let groupId = currentState.selectedGroup?.groupId else {
            return makeCalendarMutation(offset: offset)
        }

        return .concat([
            makeCalendarMutation(offset: offset),
            fetchActivityCalendar(
                groupId: groupId,
                offset: offset
            )
        ])
    }

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

    func fetchActivityCalendar(groupId: Int, offset: Int) -> Observable<Mutation> {
        asyncObservable { [weak self] in
            guard let self else { return nil }

            guard let activityCalendar = try? await self.feedUseCase.fetchActivityCalendar(
                groupId: groupId,
                baseDate: self.weekStartDateString(offset: offset)
            ) else {
                return nil
            }

            return self.makeWeekCalendarMutation(
                offset: offset,
                activityCalendar: activityCalendar
            )
        }
    }

    func makeWeekCalendarMutation(
        offset: Int,
        activityCalendar: FeedActivityCalendarModel
    ) -> Mutation {
        let recordedDates = Set(
            activityCalendar.days
                .filter(\.hasRecord)
                .map(\.date)
        )
        let targetDate = targetDate(offset: offset)
        let weekInfo = FeedWeekCalendarCalculator.calculateWeekInfoFromBaseDate(
            targetDate,
            calendar: calendar
        )
        let models = FeedWeekCalendarCalculator.makeModels(
            containing: targetDate,
            recordedDates: recordedDates,
            calendar: calendar
        )

        return .setWeekCalendar(
            offset: offset,
            title: weekInfo.title,
            dates: models
        )
    }

    func weekStartDateString(offset: Int) -> String {
        let targetDate = targetDate(offset: offset)
        let weekDates = FeedWeekCalendarCalculator.makeModels(
            containing: targetDate,
            calendar: calendar
        )

        return weekDates.first?.date ?? targetDate.toString()
    }

    func targetDate(offset: Int) -> Date {
        guard let targetDate = calendar.date(
            byAdding: .weekOfYear,
            value: offset,
            to: baseDate
        ) else {
            return baseDate
        }

        return targetDate
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

private extension FeedReactor {
    func fetchGroups() -> Observable<Mutation> {
        asyncObservable { [weak self] () -> [GroupModel]? in
            guard let self else { return nil }
            return (try? await self.groupUseCase.getGroups()) ?? []
        }
        .flatMap { [weak self] groups in
            guard let self else { return Observable<Mutation>.empty() }

            let selectedGroup = groups.first {
                $0.groupId == self.currentState.selectedGroup?.groupId
            } ?? groups.first

            return self.setGroup(selectedGroup, in: groups)
        }
    }

    func fetchMyMemberId() -> Observable<Mutation> {
        asyncObservable { [weak self] in
            guard let self,
                  let userInfo = try? await self.authUseCase.getUserInfo(
                    needUpdateKeyChain: false
                  ) else {
                return nil
            }

            return .setMyMemberId(userInfo.memberId)
        }
    }

    func withLoading(
        _ mutation: (Bool) -> Mutation,
        operation: Observable<Mutation>
    ) -> Observable<Mutation> {
        .concat([
            .just(mutation(true)),
            operation,
            .just(mutation(false))
        ])
    }

    func asyncObservable<Element>(
        _ operation: @escaping @MainActor () async -> Element?
    ) -> Observable<Element> {
        Observable.create { observer in
            let task = Task { @MainActor in
                if let element = await operation() {
                    observer.onNext(element)
                }
                observer.onCompleted()
            }

            return Disposables.create { task.cancel() }
        }
        .observe(on: MainScheduler.instance)
    }
}
