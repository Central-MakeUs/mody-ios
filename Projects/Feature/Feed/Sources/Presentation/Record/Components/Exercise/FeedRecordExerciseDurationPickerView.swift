//
//  FeedRecordExerciseDurationPickerView.swift
//  Feed
//
//  Created by 김동준 on 7/16/26.
//

import SwiftUI
import DesignSystem

struct FeedRecordExerciseDurationPickerView: View {
    @State private var hours: Int
    @State private var minutes: Int

    private let selectableHours = Array(0...6)
    private let selectableMinutes = Array(0...59)
    private let onDurationChanged: (Int, Int) -> Void

    init(
        hours: Int,
        minutes: Int,
        onDurationChanged: @escaping (Int, Int) -> Void
    ) {
        self._hours = State(initialValue: hours)
        self._minutes = State(initialValue: minutes)
        self.onDurationChanged = onDurationChanged
    }

    var body: some View {
        HStack(spacing: 0) {
            picker(
                selection: $hours,
                values: selectableHours,
                formatsWithLeadingZero: false
            )

            MText(
                "시간",
                style: .b6,
                color: .gray5
            ).padding(.trailing, 18)

            MText(
                ":",
                style: .b1,
                color: .gray10
            ).padding(.trailing, 18)

            picker(
                selection: $minutes,
                values: selectableMinutes,
                formatsWithLeadingZero: true
            )

            MText(
                "분",
                style: .b6,
                color: .gray5
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 145)
        .clipped()
        .onChange(of: hours) { _, newValue in
            onDurationChanged(newValue, minutes)
        }
        .onChange(of: minutes) { _, newValue in
            onDurationChanged(hours, newValue)
        }
    }
}

private extension FeedRecordExerciseDurationPickerView {
    func picker(
        selection: Binding<Int>,
        values: [Int],
        formatsWithLeadingZero: Bool
    ) -> some View {
        Picker("", selection: selection) {
            ForEach(values, id: \.self) { value in
                MText(
                    formatsWithLeadingZero ? String(format: "%02d", value) : "\(value)",
                    style: .b1,
                    color: .gray10
                )
                .tag(value)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .frame(width: 60, height: 145)
        .clipped()
    }
}
