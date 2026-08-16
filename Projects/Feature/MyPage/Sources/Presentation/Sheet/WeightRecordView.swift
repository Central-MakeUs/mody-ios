//
//  WeightRecordView.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import ComposableArchitecture
import CommonDomain
import DesignSystem
import SwiftUI

struct WeightRecordView: View {
    @Bindable private var store: StoreOf<WeightRecordFeature>
    @FocusState private var isDateFieldFocused: Bool

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
        .presentationDetents([
            .height(max(0, 483 - DeviceSizeManager.shared.bottomSafeAreaInset))
        ])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(36)
        .background(Color.systemWhite)
    }
}

private extension WeightRecordView {
    var inputSection: some View {
        VStack(spacing: 16) {
            dateInputField

            weightPicker
        }
        .padding(.horizontal, 24)
    }

    var dateInputField: some View {
        VStack(alignment: .leading, spacing: 12) {
            MText(
                "날짜",
                style: .b7,
                color: .gray8,
                alignment: .leading
            )

            MTextField(
                $store.dateText,
                placeholder: "",
                hasStroke: true,
                strokeColor: isDateFieldFocused && !store.dateText.isEmpty ? .main : .gray2,
                keyboardType: .decimalPad,
                focus: $isDateFieldFocused
            )
        }
    }

    var weightPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            MText(
                "현재 체중",
                style: .b7,
                color: .gray8,
                alignment: .leading
            )

            HStack(spacing: 4) {
                Picker("", selection: $store.currentWeightKg) {
                    ForEach(store.selectableWeights, id: \.self) { weight in
                        MText(
                            "\(weight)",
                            style: .b1,
                            color: .gray10
                        )
                        .tag(weight)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .frame(width: 80, height: 180)
                .clipped()

                MText(
                    "kg",
                    style: .b7,
                    color: .gray4
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}
