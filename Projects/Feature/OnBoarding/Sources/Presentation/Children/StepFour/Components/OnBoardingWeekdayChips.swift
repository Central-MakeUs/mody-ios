//
//  OnBoardingWeekdayChips.swift
//  OnBoarding
//
//  Created by 김동준 on 7/9/26
//

import SwiftUI
import DesignSystem
import Util

struct OnBoardingWeekdayChips: View {
    private let weekdays: [DayOfWeek]
    private let selectedWeekdays: [DayOfWeek]
    private let onWeekdayTapped: (DayOfWeek) -> Void
    
    init(
        weekdays: [DayOfWeek],
        selectedWeekdays: [DayOfWeek],
        onWeekdayTapped: @escaping (DayOfWeek) -> Void
    ) {
        self.weekdays = weekdays
        self.selectedWeekdays = selectedWeekdays
        self.onWeekdayTapped = onWeekdayTapped
    }

    var body: some View {
        GeometryReader { proxy in
            let chipCount = CGFloat(max(weekdays.count, 1))
            let spacingCount = CGFloat(max(weekdays.count - 1, 0))
            let spacing: CGFloat = 12
            let chipSize = max(0, min(40, (proxy.size.width - spacing * spacingCount) / chipCount))

            HStack(spacing: spacing) {
                ForEach(weekdays) { weekday in
                    Button {
                        onWeekdayTapped(weekday)
                    } label: {
                        MText(
                            weekday.title,
                            style: .b7,
                            color: .gray10
                        )
                        .frame(width: chipSize, height: chipSize)
                        .background(selectedWeekdays.contains(weekday) ? Color.main : Color.gray1)
                        .clipShape(Circle())
                    }
                    .vPadding(8)
                }
            }
            .vPadding(8)
        }
    }
}
