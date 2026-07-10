//
//  OnBoardingStepFourFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import ComposableArchitecture
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
                        date: exerciseSchedules.first { $0.dayOfWeek == dayOfWeek }?.date
                            ?? defaultExerciseDate
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
                setMealHour(&state, meal: meal, hour: hour)
                state.expandedMeal = nil
                setMealScheduleRequests(&state)
                return .none
            case .weekdayTapped(let day):
                if state.selectedWeekdays.contains(day) {
                    state.selectedWeekdays.removeAll { $0 == day }
                    state.exerciseSchedules.removeAll { $0.dayOfWeek == day }
                } else {
                    state.selectedWeekdays.append(day)
                    setExerciseDate(&state, day: day, date: state.defaultExerciseDate)
                }
                setExerciseScheduleRequests(&state)
                return .none
            case .exerciseScheduleTapped(let day):
                state.timeSheetTarget = .exerciseDay(day)
                state.timeSheetDate = exerciseDate(from: state, for: day)
                state.isTimeSheetPresented = true
                return .none
            case .sameExerciseTimeTapped:
                guard let firstDay = state.selectedWeekdays.sorted().first else { return .none }
                state.timeSheetTarget = .allExerciseDays
                state.timeSheetDate = exerciseDate(from: state, for: firstDay)
                state.isTimeSheetPresented = true
                return .none
            case .timeSheetConfirmTapped:
                guard let target = state.timeSheetTarget else { return .none }
                switch target {
                case .allExerciseDays:
                    state.selectedWeekdays.forEach { day in
                        setExerciseDate(&state, day: day, date: state.timeSheetDate)
                    }
                case .exerciseDay(let day):
                    setExerciseDate(&state, day: day, date: state.timeSheetDate)
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
        state.request.mealSchedules = makeMealScheduleRequests(from: state)
    }

    func setExerciseScheduleRequests(_ state: inout State) {
        state.request.exerciseSchedules = makeExerciseScheduleRequests(from: state)
    }

    func makeMealScheduleRequests(from state: State) -> [MealScheduleRequest] {
        state.meals.map { meal in
            MealScheduleRequest(
                mealType: meal,
                time: String.toHourMinString(hour: mealHour(from: state, for: meal), minute: 0),
                skipped: state.skippedMeals.contains(meal)
            )
        }
    }

    func makeExerciseScheduleRequests(from state: State) -> [ExerciseScheduleRequest] {
        state.selectedWeekdays
            .sorted()
            .map { dayOfWeek in
                ExerciseScheduleRequest(
                    dayOfWeek: dayOfWeek,
                    time: exerciseDate(from: state, for: dayOfWeek)
                        .toHourMinTimeString(calendar: state.calendar)
                )
            }
    }
}

private extension OnBoardingStepFourFeature {
    func mealHour(from state: State, for meal: MealType) -> Int {
        state.mealHours.first { $0.mealType == meal }?.hour ?? meal.defaultHour
    }

    func setMealHour(_ state: inout State, meal: MealType, hour: Int) {
        guard let index = state.mealHours.firstIndex(where: { $0.mealType == meal }) else {
            state.mealHours.append(MealHour(mealType: meal, hour: hour))
            return
        }
        state.mealHours[index].hour = hour
    }

    func exerciseDate(from state: State, for day: DayOfWeek) -> Date {
        state.exerciseSchedules.first { $0.dayOfWeek == day }?.date ?? state.defaultExerciseDate
    }

    func setExerciseDate(_ state: inout State, day: DayOfWeek, date: Date) {
        guard let index = state.exerciseSchedules.firstIndex(where: { $0.dayOfWeek == day }) else {
            state.exerciseSchedules.append(ExerciseSchedule(dayOfWeek: day, date: date))
            return
        }
        state.exerciseSchedules[index].date = date
    }
}
