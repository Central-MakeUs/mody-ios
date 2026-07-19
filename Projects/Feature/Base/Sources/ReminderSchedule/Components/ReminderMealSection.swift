//
//  ReminderMealSection.swift
//  Base
//
//  Created by 김동준 on 7/19/26.
//

import SwiftUI
import CommonDomain
import DesignSystem

public struct ReminderMealSection: View {
    private let meals: [MealType]
    private let mealHours: [MealHour]
    private let skippedMeals: [MealType]
    private let expandedMeal: MealType?
    private let onSkipTapped: (MealType) -> Void
    private let onDropdownTapped: (MealType) -> Void
    private let onHourTapped: (MealType, Int) -> Void

    public init(
        meals: [MealType],
        mealHours: [MealHour],
        skippedMeals: [MealType],
        expandedMeal: MealType?,
        onSkipTapped: @escaping (MealType) -> Void,
        onDropdownTapped: @escaping (MealType) -> Void,
        onHourTapped: @escaping (MealType, Int) -> Void
    ) {
        self.meals = meals
        self.mealHours = mealHours
        self.skippedMeals = skippedMeals
        self.expandedMeal = expandedMeal
        self.onSkipTapped = onSkipTapped
        self.onDropdownTapped = onDropdownTapped
        self.onHourTapped = onHourTapped
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(meals) { meal in
                mealSelector(for: meal)
            }
        }
        .greedyWidth(.leading)
        .zIndex(1)
    }
}

private extension ReminderMealSection {
    func mealSelector(for meal: MealType) -> some View {
        let hour = mealHour(for: meal)
        let isSkipped = skippedMeals.contains(meal)
        let isExpanded = expandedMeal == meal
        
        return VStack(alignment: .leading, spacing: 0) {
            MText(
                meal.title,
                style: .b6,
                color: .gray8
            ).padding(.bottom, 8)
            
            skipButton(for: meal, isSkipped: isSkipped)
                .padding(.bottom, 12)
            
            timeButton(
                meal: meal,
                hour: hour,
                isSkipped: isSkipped,
                isExpanded: isExpanded
            )
            .overlay(alignment: .topLeading) {
                dropdownList(
                    meal: meal,
                    hour: hour,
                    isExpanded: isExpanded
                )
                .padding(.top, 48)
            }
        }
        .zIndex(isExpanded ? 10 : 0)
    }
}

private extension ReminderMealSection {
    func skipButton(for meal: MealType, isSkipped: Bool) -> some View {
        Button {
            onSkipTapped(meal)
        } label: {
            HStack(spacing: 0) {
                MText(
                    "식사 안 함",
                    style: .c2,
                    color: isSkipped ? .gray10 : .gray5
                )
                
                checkImage(isSkipped)
            }
        }
    }
    
    func checkImage(_ isSkipped: Bool) -> some View {
        Image.icCheck
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(isSkipped ? Color.main0 : Color.gray5)
            .frame(width: 20, height: 20)
    }
}

private extension ReminderMealSection {
    func timeButton(
        meal: MealType,
        hour: Int,
        isSkipped: Bool,
        isExpanded: Bool
    ) -> some View {
        Button {
            onDropdownTapped(meal)
        } label: {
            HStack(spacing: 0) {
                MText(
                    "\(String(format: "%02d", hour))시",
                    style: .b4,
                    color: isSkipped ? .gray3 : .gray10
                )
                
                Spacer()
                
                arrowImage(isExpanded)
            }
            .padding(.leading, 8)
            .padding(.vertical, 12)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray2)
                    .frame(height: 1)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: isExpanded)
        .disabled(isSkipped)
    }
    
    func arrowImage(_ isExpanded: Bool) -> some View {
        (isExpanded ? Image.icArrowUp : Image.icArrowDown)
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(Color.gray3)
            .frame(width: 24, height: 24)
    }
}

private extension ReminderMealSection {
    func dropdownList(
        meal: MealType,
        hour: Int,
        isExpanded: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(meal.selectableHours, id: \.self) { selectableHour in
                Button {
                    onHourTapped(meal, selectableHour)
                } label: {
                    MText(
                        "\(String(format: "%02d", selectableHour))시",
                        style: .b4,
                        color: .gray10
                    )
                    .greedyWidth(.leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(selectableHour == hour ? Color.main4 : Color.systemWhite)
                }
            }
        }
        .background(Color.systemWhite)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12))
        .shadow(color: .systemBlack.opacity(0.1), radius: 6, x: 2, y: 2)
        .shadow(color: .systemBlack.opacity(0.1), radius: 2, x: 0, y: 0)
        .opacity(isExpanded ? 1 : 0)
        .allowsHitTesting(isExpanded)
        .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }
}

private extension ReminderMealSection {
    func mealHour(for meal: MealType) -> Int {
        mealHours.first { $0.mealType == meal }?.hour ?? meal.defaultHour
    }
}
