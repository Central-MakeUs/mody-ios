//
//  OnBoardingStepFourFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import ComposableArchitecture
import Base
import CommonDomain
import Foundation
import Util

@Reducer
public struct OnBoardingStepFourFeature {
    @ObservableState
    public struct State: Equatable {
        public enum TimeSheetTarget: Equatable {
            case allExerciseDays
            case exerciseDay(DayOfWeek)
        }

        struct Request: Equatable {
            var mealSchedules: [MealScheduleRequest] = []
            var exerciseSchedules: [ExerciseScheduleRequest] = []
        }

        let locale = Date.koreanLocale
        let timeZone = Date.koreanTimeZone
        let calendar: Calendar
        let meals = MealType.allCases
        let weekdays = DayOfWeek.allCases
        var skippedMeals: [MealType] = []
        var mealHours: [MealHour]
        var selectedWeekdays: [DayOfWeek] = []
        var exerciseSchedules: [ExerciseSchedule] = []
        var expandedMeal: MealType?
        var isTimeSheetPresented = false
        var timeSheetTarget: TimeSheetTarget?
        var timeSheetDate: Date
        var request: Request

        var isNextButtonEnabled: Bool {
            !selectedWeekdays.isEmpty && skippedMeals.count < 3
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
            self.mealHours = MealType.allCases.map {
                MealHour(mealType: $0, hour: $0.defaultHour)
            }
            self.exerciseSchedules = []
            self.timeSheetDate = Date.fixedDateForHourMinTime(
                hour: 9,
                minute: 0,
                calendar: calendar
            )
            self.request = Request(
                mealSchedules: MealType.allCases.map {
                    MealScheduleRequest(
                        mealType: $0,
                        time: String.toHourMinString(hour: $0.defaultHour, minute: 0),
                        skipped: false
                    )
                }
            )
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case mealSkipTapped(MealType)
        case mealDropdownTapped(MealType)
        case mealHourTapped(meal: MealType, hour: Int)
        case weekdayTapped(DayOfWeek)
        case exerciseScheduleTapped(DayOfWeek)
        case sameExerciseTimeTapped
        case timeSheetConfirmTapped
        case timeSheetDismissed
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .mealSkipTapped(let meal):
                state.expandedMeal = nil
                if state.skippedMeals.contains(meal) {
                    state.skippedMeals.removeAll { $0 == meal }
                } else {
                    state.skippedMeals.append(meal)
                }
                setMealScheduleRequests(&state)
                return .none
            case .mealDropdownTapped(let meal):
                guard !state.skippedMeals.contains(meal) else { return .none }
                state.expandedMeal = state.expandedMeal == meal ? nil : meal
                return .none
            case let .mealHourTapped(meal, hour):
                state.mealHours.setHour(hour, for: meal)
                state.expandedMeal = nil
                setMealScheduleRequests(&state)
                return .none
            case .weekdayTapped(let day):
                if state.selectedWeekdays.contains(day) {
                    state.selectedWeekdays.removeAll { $0 == day }
                    state.exerciseSchedules.removeAll { $0.dayOfWeek == day }
                } else {
                    state.selectedWeekdays.append(day)
                    state.exerciseSchedules.setDate(state.defaultExerciseDate, for: day)
                }
                setExerciseScheduleRequests(&state)
                return .none
            case .exerciseScheduleTapped(let day):
                state.timeSheetTarget = .exerciseDay(day)
                state.timeSheetDate = state.exerciseSchedules.date(
                    for: day,
                    default: state.defaultExerciseDate
                )
                state.isTimeSheetPresented = true
                return .none
            case .sameExerciseTimeTapped:
                guard let firstDay = state.selectedWeekdays.sorted().first else { return .none }
                state.timeSheetTarget = .allExerciseDays
                state.timeSheetDate = state.exerciseSchedules.date(
                    for: firstDay,
                    default: state.defaultExerciseDate
                )
                state.isTimeSheetPresented = true
                return .none
            case .timeSheetConfirmTapped:
                guard let target = state.timeSheetTarget else { return .none }
                switch target {
                case .allExerciseDays:
                    state.selectedWeekdays.forEach { day in
                        state.exerciseSchedules.setDate(state.timeSheetDate, for: day)
                    }
                case .exerciseDay(let day):
                    state.exerciseSchedules.setDate(state.timeSheetDate, for: day)
                }
                state.isTimeSheetPresented = false
                state.timeSheetTarget = nil
                setExerciseScheduleRequests(&state)
                return .none
            case .timeSheetDismissed:
                state.timeSheetTarget = nil
                return .none
            }
        }
    }
}

private extension OnBoardingStepFourFeature {
    func setMealScheduleRequests(_ state: inout State) {
        state.request.mealSchedules = MealScheduleRequest.makeMealScheduleRequests(
            meals: state.meals,
            skippedMeals: state.skippedMeals,
            timeForMeal: { meal in
                String.toHourMinString(
                    hour: state.mealHours.hour(for: meal),
                    minute: 0
                )
            }
        )
    }

    func setExerciseScheduleRequests(_ state: inout State) {
        state.request.exerciseSchedules = ExerciseScheduleRequest.makeExerciseScheduleRequests(
            selectedWeekdays: state.selectedWeekdays,
            timeForDay: { dayOfWeek in
                state.exerciseSchedules
                    .date(for: dayOfWeek, default: state.defaultExerciseDate)
                    .toHourMinTimeString(calendar: state.calendar)
            }
        )
    }
}
