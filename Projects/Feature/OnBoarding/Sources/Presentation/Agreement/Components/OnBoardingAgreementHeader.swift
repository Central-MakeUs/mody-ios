//
//  OnBoardingAgreementHeader.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import DesignSystem
import SwiftUI

struct OnBoardingAgreementHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MText(
                "필수 약관에 동의해주세요",
                style: .h2,
                color: .gray10,
                alignment: .leading
            )

            MText(
                "MODY를 시작하려면 약관 동의가 필요해요.",
                style: .b7,
                color: .gray6,
                alignment: .leading
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
