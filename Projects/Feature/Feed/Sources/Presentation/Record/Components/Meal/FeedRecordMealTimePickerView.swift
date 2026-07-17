//
//  FeedRecordMealTimePickerView.swift
//  Feed
//
//  Created by 김동준 on 7/16/26.
//

import SwiftUI

struct FeedRecordMealTimePickerView: View {
    @State private var date: Date

    private let onDateChanged: (Date) -> Void
    private let locale = Locale(identifier: "ko_KR")
    private let calendar = Calendar(identifier: .gregorian)
    private let timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current

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
        .environment(\.timeZone, timeZone)
        .frame(height: 145)
        .clipped()
        .onChange(of: date) { _, newValue in
            onDateChanged(newValue)
        }
    }
}
