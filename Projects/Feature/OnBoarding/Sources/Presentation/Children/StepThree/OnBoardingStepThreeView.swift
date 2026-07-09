//
//  OnBoardingStepThreeView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/2/26
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct OnBoardingStepThreeView: View {
    @Bindable private var store: StoreOf<OnBoardingStepThreeFeature>

    public init(store: StoreOf<OnBoardingStepThreeFeature>) {
        self.store = store
    }

    public var body: some View {
        stepThreeBody
    }
    
    private var stepThreeBody: some View {
        VStack(spacing: 0) {
            titleText
                .padding(.bottom, 60)

            weightPickerSection
                .padding(.bottom, 32)

            validationText

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private extension OnBoardingStepThreeView {
    var titleText: some View {
        VStack(alignment: .leading, spacing: 8) {
            MText(
                "체중을 입력해주세요",
                style: .h2,
                color: .gray10,
                alignment: .leading
            )
            
            MText(
                "현재 체중과 목표 체중이 필요해요.",
                style: .b7,
                color: .gray6,
                alignment: .leading
            )
        }
        .greedyWidth(.leading)
    }
}

private extension OnBoardingStepThreeView {
    var weightPickerSection: some View {
        HStack(alignment: .top, spacing: 48) {
            weightPickerColumn(
                title: "현재 체중",
                selection: $store.currentWeightKg
            )

            weightPickerColumn(
                title: "목표 체중",
                selection: $store.targetWeightKg
            )
        }
        .greedyWidth()
    }

    func weightPickerColumn(
        title: String,
        selection: Binding<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            MText(
                title,
                style: .b6,
                color: .gray8
            )
            .width(80)

            HStack(spacing: 4) {
                Picker("", selection: selection) {
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
                .frame(width: 80, height: 153)
                .clipped()

                MText(
                    "kg",
                    style: .b7,
                    color: .gray4
                )
            }
        }
    }
}

private extension OnBoardingStepThreeView {
    @ViewBuilder
    var validationText: some View {
        switch store.goalStatus {
        case .lose(let weightDifference):
            weightDifferenceText(
                weightDifference: weightDifference,
                suffix: " 감량이 필요해요!"
            )
        case .maintain:
            MText(
                "현재 목표 체중을 유지하고 있어요!",
                style: .c1,
                color: .gray6
            )
        case .gain(let weightDifference):
            weightDifferenceText(
                weightDifference: weightDifference,
                suffix: " 증량이 필요해요!"
            )
        }
    }

    func weightDifferenceText(
        weightDifference: Int,
        suffix: String
    ) -> some View {
        (
            Text("목표까지 ")
                .font(ModyTypography.c1.token.swiftUIFont)
                .foregroundStyle(Color.gray6)
            + Text("\(weightDifference)kg")
                .font(ModyTypography.b6.token.swiftUIFont)
                .foregroundStyle(Color.sub)
            + Text(suffix)
                .font(ModyTypography.c1.token.swiftUIFont)
                .foregroundStyle(Color.gray6)
        )
    }
}
