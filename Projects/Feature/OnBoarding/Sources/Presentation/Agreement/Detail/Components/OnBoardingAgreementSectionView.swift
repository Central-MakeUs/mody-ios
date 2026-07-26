//
//  OnBoardingAgreementSectionView.swift
//  OnBoarding
//
//  Created by 김동준 on 7/26/26.
//

import DesignSystem
import SwiftUI

struct OnBoardingAgreementSectionView: View {
    private let section: OnBoardingAgreementSection

    init(section: OnBoardingAgreementSection) {
        self.section = section
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MText(
                section.title,
                style: .b3,
                color: .gray9,
                lineLimit: nil,
                alignment: .leading
            )

            MText(
                section.body,
                style: .c2,
                color: .gray9,
                lineLimit: nil,
                alignment: .leading
            )
        }
    }
}
