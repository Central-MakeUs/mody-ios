//
//  OnBoardingStepTwoView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct OnBoardingStepTwoView: View {
    @Bindable private var store: StoreOf<OnBoardingStepTwoFeature>

    public init(store: StoreOf<OnBoardingStepTwoFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            titleText
                .padding(.bottom, 60)

            datePicker

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private extension OnBoardingStepTwoView {
    var titleText: some View {
        VStack(alignment: .leading, spacing: 8) {
            MText(
                "생년월일을 입력해주세요",
                style: .h2,
                color: .gray10,
                alignment: .leading
            )

            MText(
                "한국나이로 14세 이상부터 사용할 수 있어요!",
                style: .b7,
                color: .gray6,
                alignment: .leading
            )
        }
        .greedyWidth(.leading)
    }
}

private extension OnBoardingStepTwoView {
    var datePicker: some View {
        DatePicker(
            "",
            selection: $store.birthDate,
            in: store.selectableDateRange,
            displayedComponents: [.date]
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .environment(\.locale, store.locale)
        .environment(\.calendar, store.calendar)
        .environment(\.timeZone, store.timeZone)
        .frame(height: 145)
    }
}
