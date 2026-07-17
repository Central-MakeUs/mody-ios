//
//  WeightRecordView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

struct WeightRecordView: View {
    @Bindable private var store: StoreOf<WeightRecordFeature>
    @FocusState private var isDateFieldFocused: Bool
    @FocusState private var isCurrentWeightFieldFocused: Bool

    init(store: StoreOf<WeightRecordFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            inputSection
                .padding(.top, 36)
                .padding(.bottom, 28)

            MButton(
                "기록 완료",
                style: store.isRecordButtonDisabled ? .gray : .primary,
                isDisabled: store.isRecordButtonDisabled,
                horizontalPadding: 0,
                verticalPadding: 13,
                maxWidth: .infinity
            ) {
                store.send(.recordButtonTapped)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .presentationDetents([.height(333)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(36)
        .background(Color.systemWhite)
    }
}

private extension WeightRecordView {
    var inputSection: some View {
        VStack(spacing: 16) {
            inputField(
                title: "날짜",
                text: $store.dateText,
                keyboardType: .decimalPad,
                focus: $isDateFieldFocused
            )

            inputField(
                title: "현재 체중",
                text: $store.currentWeightText,
                keyboardType: .decimalPad,
                focus: $isCurrentWeightFieldFocused
            )
        }
        .padding(.horizontal, 24)
    }

    func inputField(
        title: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType,
        focus: FocusState<Bool>.Binding
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            MText(
                title,
                style: .b7,
                color: .gray8,
                alignment: .leading
            )

            MTextField(
                text,
                placeholder: "",
                hasStroke: true,
                strokeColor: focus.wrappedValue && !text.wrappedValue.isEmpty ? .main : .gray2,
                keyboardType: keyboardType,
                focus: focus
            )
        }
    }
}
