//
//  NotificationSettingsFeature.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import Base
import CommonDomain
import ComposableArchitecture
import CoreAnalyticsInterface
import CoreNotificationInterface
import Foundation
import MyPageInterface
import Util

@Reducer
public struct NotificationSettingsFeature {
    private let notificationPermission: NotificationPermissionInterface
    private let notificationSettingUseCase: MyPageNotificationSettingUseCase
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private let router: @MainActor (MyPageNotificationSettingsRoute) -> Void

    public init(
        notificationPermission: NotificationPermissionInterface,
        notificationSettingUseCase: MyPageNotificationSettingUseCase,
        analyticsUseCase: AnalyticsUseCaseProtocol,
        router: @escaping @MainActor (MyPageNotificationSettingsRoute) -> Void
    ) {
        self.notificationPermission = notificationPermission
        self.notificationSettingUseCase = notificationSettingUseCase
        self.analyticsUseCase = analyticsUseCase
        self.router = router
    }

    @ObservableState
    public struct State: Equatable {
        public enum AlertCase: Equatable {
            case success
            case error(NetworkError)
        }

        public enum NotificationSettingType: Equatable {
            case comment
            case challenge
            case mealAndExercise
        }

        public enum TimeSheetTarget: Equatable {
            case allExerciseDays
            case exerciseDay(DayOfWeek)
        }

        let locale = Date.koreanLocale
        let timeZone = Date.koreanTimeZone
        let calendar: Calendar
        var alertCase: AlertCase?
        var alertState = AlertFeature.State()
        var isLoading = false
        var isNotificationPermissionGranted = false
        var notificationSetting = NotificationSettingState()
        var expandedMeal: MealType?
        var isTimeSheetPresented = false
        var timeSheetTarget: TimeSheetTarget?
        var timeSheetDate: Date

        var meals: [MealType] {
            MealType.allCases
        }

        var weekdays: [DayOfWeek] {
            DayOfWeek.allCases
        }

        var skippedMeals: [MealType] {
            notificationSetting.mealSchedules
                .filter(\.skipped)
                .map(\.mealType)
        }

        var mealHours: [MealHour] {
            meals.map { meal in
                let hour = notificationSetting.mealSchedules
                    .first { $0.mealType == meal }?
                    .time?
                    .toHourMinDate(calendar: calendar)
                    .map { calendar.component(.hour, from: $0) }
                    ?? meal.defaultHour

                return MealHour(mealType: meal, hour: hour)
            }
        }

        var selectedWeekdays: [DayOfWeek] {
            notificationSetting.exerciseSchedules.map(\.dayOfWeek)
        }

        var exerciseSchedules: [ExerciseSchedule] {
            notificationSetting.exerciseSchedules.compactMap { schedule in
                guard let date = schedule.time.toHourMinDate(calendar: calendar) else {
                    return nil
                }
                return ExerciseSchedule(dayOfWeek: schedule.dayOfWeek, date: date)
            }
        }

        var isSaveButtonEnabled: Bool {
            notificationSetting.mealAndExerciseEnabled
                && !selectedWeekdays.isEmpty
                && skippedMeals.count < meals.count
                && !isLoading
        }

        var sortedExerciseSchedules: [ExerciseSchedule] {
            selectedWeekdays
                .sorted()
                .map { dayOfWeek in
                    ExerciseSchedule(
                        dayOfWeek: dayOfWeek,
                        date: exerciseSchedules.date(
                            for: dayOfWeek,
                            default: defaultExerciseDate
                        )
                    )
                }
        }

        var defaultExerciseDate: Date {
            Date.fixedDateForHourMinTime(hour: 9, minute: 0, calendar: calendar)
        }

        public init() {
            let calendar = Date.koreanCalendar

            self.calendar = calendar
            self.timeSheetDate = Date.fixedDateForHourMinTime(
                hour: 9,
                minute: 0,
                calendar: calendar
            )
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case alertAction(AlertFeature.Action)
        case showAlert(State.AlertCase)
        case onAppear
        case checkNotificationPermission
        case backButtonTapped
        case notificationToggleChanged(State.NotificationSettingType, isOn: Bool)
        case mealSkipTapped(MealType)
        case mealDropdownTapped(MealType)
        case mealHourTapped(meal: MealType, hour: Int)
        case weekdayTapped(DayOfWeek)
        case exerciseScheduleTapped(DayOfWeek)
        case sameExerciseTimeTapped
        case timeSheetConfirmTapped
        case timeSheetDismissed
        case saveButtonTapped
        case notificationSettingsFetched(NotificationSettingState)
        case notificationSettingsFetchFailed(NetworkError)
        case notificationSettingsUpdated(NotificationSettingState)
        case notificationSettingsUpdateFailed(NetworkError)
        case schedulesUpdated
        case schedulesUpdateFailed(NetworkError)
        case setNotificationPermissionGranted(Bool)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.alertState, action: \.alertAction) {
            AlertFeature()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .alertAction:
                return .none
            case let .showAlert(alertCase):
                state.isLoading = false
                state.alertCase = alertCase
                return .send(.alertAction(.present))
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .send(.checkNotificationPermission),
                    .run { send in
                        await send(fetchNotificationSettings())
                    }
                )
            case .checkNotificationPermission:
                return .run { send in
                    let isGranted = await currentNotificationPermissionIsGranted()
                    await send(.setNotificationPermissionGranted(isGranted))
                }
            case .backButtonTapped:
                return .run { [router] _ in
                    await router(.back)
                }
            case let .notificationToggleChanged(type, isOn):
                state.isLoading = true
                var settingState = state.notificationSetting

                switch type {
                case .comment:
                    settingState.commentNotificationEnabled = isOn
                case .challenge:
                    settingState.challengeNotificationEnabled = isOn
                case .mealAndExercise:
                    settingState.mealAndExerciseEnabled = isOn
                }

                return .run { [settingState] send in
                    await send(updateNotificationSettings(settingState))
                }
            case .mealSkipTapped(let meal):
                state.expandedMeal = nil
                var skippedMeals = state.skippedMeals

                if skippedMeals.contains(meal) {
                    skippedMeals.removeAll { $0 == meal }
                } else {
                    skippedMeals.append(meal)
                }

                state.notificationSetting.mealSchedules = MealScheduleRequest.makeMealScheduleRequests(
                    meals: state.meals,
                    skippedMeals: skippedMeals,
                    timeForMeal: { meal in
                        String.toHourMinString(
                            hour: state.mealHours.hour(for: meal),
                            minute: 0
                        )
                    }
                )
                return .none
            case .mealDropdownTapped(let meal):
                guard !state.skippedMeals.contains(meal) else { return .none }
                state.expandedMeal = state.expandedMeal == meal ? nil : meal
                return .none
            case let .mealHourTapped(meal, hour):
                var mealHours = state.mealHours
                mealHours.setHour(hour, for: meal)
                state.expandedMeal = nil
                state.notificationSetting.mealSchedules = MealScheduleRequest.makeMealScheduleRequests(
                    meals: state.meals,
                    skippedMeals: state.skippedMeals,
                    timeForMeal: { meal in
                        String.toHourMinString(
                            hour: mealHours.hour(for: meal),
                            minute: 0
                        )
                    }
                )
                return .none
            case .weekdayTapped(let day):
                var selectedWeekdays = state.selectedWeekdays
                var exerciseSchedules = state.exerciseSchedules

                if selectedWeekdays.contains(day) {
                    selectedWeekdays.removeAll { $0 == day }
                    exerciseSchedules.removeAll { $0.dayOfWeek == day }
                } else {
                    selectedWeekdays.append(day)
                    exerciseSchedules.setDate(state.defaultExerciseDate, for: day)
                }

                state.notificationSetting.exerciseSchedules = ExerciseScheduleRequest.makeExerciseScheduleRequests(
                    selectedWeekdays: selectedWeekdays,
                    timeForDay: { dayOfWeek in
                        exerciseSchedules
                            .date(for: dayOfWeek, default: state.defaultExerciseDate)
                            .toHourMinTimeString(calendar: state.calendar)
                    }
                )
                return .none
            case .exerciseScheduleTapped(let day):
                state.timeSheetTarget = .exerciseDay(day)
                state.timeSheetDate = state.exerciseSchedules.date(for: day, default: state.defaultExerciseDate)
                state.isTimeSheetPresented = true
                return .none
            case .sameExerciseTimeTapped:
                guard let firstDay = state.selectedWeekdays.sorted().first else { return .none }
                state.timeSheetTarget = .allExerciseDays
                state.timeSheetDate = state.exerciseSchedules.date(for: firstDay, default: state.defaultExerciseDate)
                state.isTimeSheetPresented = true
                return .none
            case .timeSheetConfirmTapped:
                guard let target = state.timeSheetTarget else { return .none }
                var exerciseSchedules = state.exerciseSchedules

                switch target {
                case .allExerciseDays:
                    state.selectedWeekdays.forEach { day in
                        exerciseSchedules.setDate(state.timeSheetDate, for: day)
                    }
                case .exerciseDay(let day):
                    exerciseSchedules.setDate(state.timeSheetDate, for: day)
                }

                state.notificationSetting.exerciseSchedules = ExerciseScheduleRequest.makeExerciseScheduleRequests(
                    selectedWeekdays: state.selectedWeekdays,
                    timeForDay: { dayOfWeek in
                        exerciseSchedules
                            .date(for: dayOfWeek, default: state.defaultExerciseDate)
                            .toHourMinTimeString(calendar: state.calendar)
                    }
                )
                state.isTimeSheetPresented = false
                state.timeSheetTarget = nil
                return .none
            case .timeSheetDismissed:
                state.timeSheetTarget = nil
                return .none
            case .saveButtonTapped:
                guard state.isSaveButtonEnabled else { return .none }
                let mealSchedules = state.notificationSetting.mealSchedules
                let exerciseSchedules = state.notificationSetting.exerciseSchedules
                state.isLoading = true
                return .run { [mealSchedules, exerciseSchedules] send in
                    await send(updateSchedules(mealSchedules: mealSchedules, exerciseSchedules: exerciseSchedules))
                }
            case .notificationSettingsFetched(let notificationSetting):
                state.isLoading = false
                state.notificationSetting = notificationSetting
                return .none
            case let .notificationSettingsFetchFailed(error):
                return .send(.showAlert(.error(error)))
            case .notificationSettingsUpdated(let notificationSetting):
                state.isLoading = false
                state.notificationSetting = notificationSetting
                return .run { _ in
                    analyticsUseCase.log(
                        MyPageAnalyticsEvent.notificationSettingsUpdated(notificationSetting)
                    )
                }
            case let .notificationSettingsUpdateFailed(error):
                return .send(.showAlert(.error(error)))
            case .schedulesUpdated:
                let notificationSetting = state.notificationSetting
                return .merge(
                    .run { _ in
                        analyticsUseCase.log(
                            MyPageAnalyticsEvent.notificationSettingsUpdated(notificationSetting)
                        )
                    },
                    .send(.showAlert(.success))
                )
            case let .schedulesUpdateFailed(error):
                return .send(.showAlert(.error(error)))
            case .setNotificationPermissionGranted(let isGranted):
                state.isNotificationPermissionGranted = isGranted
                return .none
            }
        }
    }
}

private extension NotificationSettingsFeature {
    func currentNotificationPermissionIsGranted() async -> Bool {
        let isNotDetermined = await notificationPermission.isNotificationPermissionNotDetermined()
        if isNotDetermined {
            return await notificationPermission.requestNotificationPermission()
        }

        return await notificationPermission.isNotificationPermissionGranted()
    }

    func fetchNotificationSettings() async -> Action {
        do {
            let notificationSetting = try await notificationSettingUseCase.fetchNotificationSettings()
            return .notificationSettingsFetched(notificationSetting)
        } catch {
            return .notificationSettingsFetchFailed(error as? NetworkError ?? .unknown)
        }
    }

    func updateNotificationSettings(_ notificationSetting: NotificationSettingState) async -> Action {
        do {
            let updatedNotificationSetting = try await notificationSettingUseCase.updateNotificationSettings(
                notificationSetting
            )
            return .notificationSettingsUpdated(updatedNotificationSetting)
        } catch {
            return .notificationSettingsUpdateFailed(error as? NetworkError ?? .unknown)
        }
    }

    func updateSchedules(
        mealSchedules: [MealScheduleRequest],
        exerciseSchedules: [ExerciseScheduleRequest]
    ) async -> Action {
        do {
            try await notificationSettingUseCase.updateSchedules(
                mealSchedules: mealSchedules,
                exerciseSchedules: exerciseSchedules
            )
            return .schedulesUpdated
        } catch {
            return .schedulesUpdateFailed(error as? NetworkError ?? .unknown)
        }
    }
}
