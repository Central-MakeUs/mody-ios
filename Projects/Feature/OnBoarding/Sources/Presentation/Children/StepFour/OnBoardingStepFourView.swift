//
//  OnBoardingStepFourView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI
import Base
import ComposableArchitecture
import DesignSystem

public struct OnBoardingStepFourView: View {
    @Bindable private var store: StoreOf<OnBoardingStepFourFeature>

    public init(store: StoreOf<OnBoardingStepFourFeature>) {
        self.store = store
    }

    public var body: some View {
        stepFourBody
            .sheet(
                isPresented: $store.isTimeSheetPresented,
                onDismiss: { store.send(.timeSheetDismissed) }
            ) {
                ReminderExerciseTimeSheet(
                    date: $store.timeSheetDate,
                    locale: store.locale,
                    calendar: store.calendar,
                    timeZone: store.timeZone
                ) {
                    store.send(.timeSheetConfirmTapped)
                }
            }
    }

    private var stepFourBody: some View {
        GeometryReader { proxy in
            let contentWidth = proxy.size.width - 48

            ScrollView {
                VStack(spacing: 0) {
                    titleText
                        .padding(.bottom, 48)

                    mealSection
                        .padding(.bottom, 36)

                    exerciseSection(width: contentWidth)
                        .padding(.bottom, 24)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

private extension OnBoardingStepFourView {
    var titleText: some View {
        MText(
            "식사와 운동 알림을\n언제 드릴까요?",
            style: .h2,
            color: .gray10,
            lineLimit: 2,
            alignment: .leading
        )
        .greedyWidth(.leading)
    }
}

private extension OnBoardingStepFourView {
    var mealSection: some View {
        ReminderMealSection(
            meals: store.meals,
            mealHours: store.mealHours,
            skippedMeals: store.skippedMeals,
            expandedMeal: store.expandedMeal,
            onSkipTapped: { meal in
                store.send(.mealSkipTapped(meal))
            },
            onDropdownTapped: { meal in
                store.send(.mealDropdownTapped(meal), animation: .easeInOut(duration: 0.18))
            },
            onHourTapped: { meal, hour in
                store.send(.mealHourTapped(meal: meal, hour: hour), animation: .easeInOut(duration: 0.18))
            }
        )
    }
}

private extension OnBoardingStepFourView {
    func exerciseSection(width: CGFloat) -> some View {
        ReminderExerciseSection(
            width: width,
            weekdays: store.weekdays,
            selectedWeekdays: store.selectedWeekdays,
            schedules: store.sortedExerciseSchedules,
            calendar: store.calendar,
            onWeekdayTapped: { weekday in
                store.send(.weekdayTapped(weekday), animation: .easeInOut(duration: 0.18))
            },
            onScheduleTapped: { weekday in
                store.send(.exerciseScheduleTapped(weekday))
            },
            onSameTimeTapped: {
                store.send(.sameExerciseTimeTapped)
            }
        )
    }
}
