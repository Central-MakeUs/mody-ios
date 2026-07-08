//
//  OnBoardingStepTwoFeature.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import ComposableArchitecture
import Foundation

@Reducer
public struct OnBoardingStepTwoFeature {
    @ObservableState
    public struct State: Equatable {
        let locale = Locale(identifier: "ko_KR")
        let timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        let calendar: Calendar
        let minimumAvailableAge = 14
        let minimumBirthDate: Date
        let maximumBirthDate: Date
        var isNextButtonEnabled: Bool = true
        var birthDate: Date

        var selectableDateRange: ClosedRange<Date> {
            minimumBirthDate...maximumBirthDate
        }

        public init() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = locale
            calendar.timeZone = timeZone

            self.calendar = calendar
            self.minimumBirthDate = calendar.date(
                from: DateComponents(year: 1960, month: 1, day: 1)
            ) ?? Date()
            let maximumBirthYear = calendar.component(.year, from: Date()) - minimumAvailableAge
            self.maximumBirthDate = calendar.date(
                from: DateComponents(year: maximumBirthYear, month: 12, day: 31)
            ) ?? Date()
            let defaultBirthDate = calendar.date(
                from: DateComponents(year: 2003, month: 3, day: 19)
            ) ?? Date()
            self.birthDate = min(defaultBirthDate, maximumBirthDate)
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            return .none
        }
    }
}
