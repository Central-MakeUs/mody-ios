//
//  FeedRecordMealTimePickerView.swift
//  Feed
//
//  Created by 김동준 on 7/16/26.
//

import SwiftUI
import Util

struct FeedRecordMealTimePickerView: View {
    @State private var date: Date

    private let onDateChanged: (Date) -> Void
    private let locale = Date.koreanLocale
    private let calendar = Date.koreanCalendar

    init(
        date: Date,
        onDateChanged: @escaping (Date) -> Void
    ) {
        self._date = State(initialValue: date)
        self.onDateChanged = onDateChanged
    }

    var body: some View {
        DatePicker(
            "",
            selection: $date,
            displayedComponents: [.hourAndMinute]
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .environment(\.locale, locale)
        .environment(\.calendar, calendar)
        .environment(\.timeZone, calendar.timeZone)
        .frame(height: 145)
        .clipped()
        .onChange(of: date) { _, newValue in
            onDateChanged(newValue)
        }
    }
}
