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
import FeedInterface

public final class FeedReactor: Reactor {
    private let groupUseCase: GroupUseCaseProtocol
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
        router: FeedRouter
    ) {
        self.groupUseCase = groupUseCase
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
            return .concat([
                .just(.setFetchGroupLoading(true)),
                fetchGroups(),
                .just(.setFetchGroupLoading(false))
            ])
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
            return .just(.setSelectedGroup(group))
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
            if newState.selectedGroup == nil, groups.count > 0 {
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
    func fetchGroups() -> Observable<Mutation> {
        Observable.create { [weak self] observer in
            let task = Task {
                guard let self else { return }
                do {
                    try await Task.sleep(for: .seconds(1)) // MARK: 현재 응답이 너무 빨라 테스트 용으로 넣었음. (스켈레톤 볼려고)
                    let groups = try await self.groupUseCase.getGroups()
                    observer.onNext(.setGroups(groups))
                } catch {
                    observer.onError(error)
                }

                observer.onCompleted()
            }

            return Disposables.create { task.cancel() }
        }
        .observe(on: MainScheduler.instance)
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
