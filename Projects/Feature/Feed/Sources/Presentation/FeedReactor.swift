//
//  FeedReactor.swift
//  Feed
//
//  Created by 김동준 on 7/11/26
//

import Foundation
import CommonDomain
import FeedInterface
import ModyGroupInterface
import ReactorKit

public final class FeedReactor: Reactor {
    private let groupUseCase: GroupUseCaseProtocol
    private let feedUseCase: FeedUseCaseProtocol
    private weak var router: FeedRouter?
    public let initialState: State
    private let baseDate: Date
    private let calendar: Calendar

    public struct State {
        var isFloatingActionButtonExpanded = false
        var groups: [GroupModel] = []
        var selectedGroup: GroupModel?
        var isFetchGroupLoading = false

        var weekCalendarViewState: FeedWeekCalendarViewState
        var weekOffset = 0
    }
    
    public enum Mutation {
        case setFloatingActionButtonExpanded(Bool)
        case setGroups([GroupModel])
        case setSelectedGroup(GroupModel)
        case setFetchGroupLoading(Bool)

        case setWeekCalendar(
            offset: Int,
            title: String,
            dates: [FeedWeekCalendarModel]
        )
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
        
        case didTapRecordButton(FeedRecordType)
    }
    
    public init(
        groupUseCase: GroupUseCaseProtocol,
        feedUseCase: FeedUseCaseProtocol,
        router: FeedRouter
    ) {
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
            return fetchGroupsWithLoading()
        case .input(.refreshGroups):
            return fetchGroupsWithLoading()
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
                fetchActivityCalendar(
                    groupId: group.groupId,
                    offset: currentState.weekOffset
                )
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

            return .just(.setSelectedCalendarDate(model.date))
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
            if let selectedGroup = newState.selectedGroup,
               let refreshedSelectedGroup = groups.first(where: { $0.groupId == selectedGroup.groupId }) {
                newState.selectedGroup = refreshedSelectedGroup
            } else {
                newState.selectedGroup = groups.first
            }
        case .setSelectedGroup(let group):
            newState.selectedGroup = group
        case .setFetchGroupLoading(let isLoading):
            newState.isFetchGroupLoading = isLoading
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
    func fetchGroupsWithLoading() -> Observable<Mutation> {
        .concat([
            .just(.setFetchGroupLoading(true)),
            fetchGroups(),
            fetchSelectedGroupActivityCalendar(),
            .just(.setFetchGroupLoading(false))
        ])
    }

    func fetchGroups() -> Observable<Mutation> {
        Observable.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                do {
                    try await Task.sleep(for: .seconds(1)) // MARK: 현재 응답이 너무 빨라 테스트 용으로 넣었음. (스켈레톤 볼려고)
                    let groups = try await self.groupUseCase.getGroups()
                    await MainActor.run {
                        observer.onNext(.setGroups(groups))
                    }
                } catch {
                    await MainActor.run {
                        observer.onError(error)
                    }
                }

                await MainActor.run {
                    observer.onCompleted()
                }
            }

            return Disposables.create { task.cancel() }
        }
        .observe(on: MainScheduler.instance)
    }

    func fetchSelectedGroupActivityCalendar() -> Observable<Mutation> {
        .deferred { [weak self] in
            guard let self,
                  let groupId = self.currentState.selectedGroup?.groupId else {
                return .empty()
            }

            return self.fetchActivityCalendar(
                groupId: groupId,
                offset: self.currentState.weekOffset
            )
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
        Observable.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                do {
                    let activityCalendar = try await self.feedUseCase.fetchActivityCalendar(
                        groupId: groupId,
                        baseDate: self.weekStartDateString(offset: offset)
                    )
                    observer.onNext(self.makeWeekCalendarMutation(
                        offset: offset,
                        activityCalendar: activityCalendar
                    ))
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create { task.cancel() }
        }
        .observe(on: MainScheduler.instance)
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
