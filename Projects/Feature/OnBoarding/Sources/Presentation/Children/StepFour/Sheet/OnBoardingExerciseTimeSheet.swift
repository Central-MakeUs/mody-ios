//
//  OnBoardingExerciseTimeSheet.swift
//  OnBoarding
//
//  Created by 김동준 on 7/9/26
//

import SwiftUI
import DesignSystem

struct OnBoardingExerciseTimeSheet: View {
    @Binding private var date: Date

    private let locale: Locale
    private let calendar: Calendar
    private let timeZone: TimeZone
    private let onConfirmTapped: () -> Void

    init(
        date: Binding<Date>,
        locale: Locale,
        calendar: Calendar,
        timeZone: TimeZone,
        onConfirmTapped: @escaping () -> Void
    ) {
        self._date = date
        self.locale = locale
        self.calendar = calendar
        self.timeZone = timeZone
        self.onConfirmTapped = onConfirmTapped
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            DatePicker(
                "",
                selection: $date,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, locale)
            .environment(\.calendar, calendar)
            .environment(\.timeZone, timeZone)
            .frame(height: 145)

            Spacer()

            MButton(
                "확인",
                style: .primary,
                verticalPadding: 13,
                maxWidth: .infinity
            ) {
                onConfirmTapped()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .presentationDetents([.height(370)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(36)
        .background(Color.systemWhite)
    }
}
