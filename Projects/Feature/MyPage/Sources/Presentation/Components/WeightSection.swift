//
//  WeightSection.swift
//  MyPage
//
//  Created by 김동준 on 7/17/26.
//

import DesignSystem
import Foundation
import SwiftUI

struct WeightSection: View {
    let weightRecord: WeightRecord?
    let onRecordButtonTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MText(
                "체중 기록",
                style: .b3,
                color: .gray10,
                alignment: .leading
            )

            VStack(spacing: 16) {
                weightSummary
                weightRecordButton
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .background(Color.gray1)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private extension WeightSection {
    var weightSummary: some View {
        HStack(spacing: 0) {
            weightItem(
                title: "시작 체중",
                weight: weightRecord?.startWeightKg
            )

            Spacer()
            weightArrow
            Spacer()

            weightItem(
                title: "현재 체중",
                weight: weightRecord?.currentWeightKg
            )

            Spacer()
            weightArrow
            Spacer()

            weightItem(
                title: "목표 체중",
                weight: weightRecord?.targetWeightKg
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.systemWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    func weightItem(title: String, weight: Double?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            MText(
                title,
                style: .c2,
                color: .gray5,
                alignment: .leading
            )

            if let weight {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    MText(
                        formattedWeight(weight),
                        style: .h2,
                        color: .gray10,
                        alignment: .leading
                    )

                    MText(
                        "kg",
                        style: .b7,
                        color: .gray8,
                        alignment: .leading
                    )
                }
            } else {
                SkeletonView(width: 50, height: 34)
            }
        }
    }

    func formattedWeight(_ weight: Double) -> String {
        let roundedWeight = weight.rounded()
        if abs(weight - roundedWeight) < 0.000_1 {
            return String(Int(roundedWeight))
        }

        return String(format: "%.1f", weight)
    }

    var weightArrow: some View {
        Image.icRightArrow
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(Color.gray2)
            .frame(width: 24, height: 24)
    }
}

private extension WeightSection {
    var weightRecordButton: some View {
        Button(action: onRecordButtonTapped) {
            MText(
                "체중 기록하기",
                style: .b6,
                color: .systemWhite
            )
            .greedyWidth()
            .vPadding(9)
            .background(Color.gray9)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(weightRecord == nil)
    }

}
