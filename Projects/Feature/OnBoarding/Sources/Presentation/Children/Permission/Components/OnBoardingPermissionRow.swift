//
//  OnBoardingPermissionRow.swift
//  OnBoarding
//
//  Created by 김동준 on 7/20/26.
//

import DesignSystem
import SwiftUI

struct OnBoardingPermissionRow: View {
    let icon: Image
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 20) {
            icon
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.gray9)
                .frame(width: 24, height: 24)
                .frame(width: 48, height: 48)
                .background(Color.gray1)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                MText(
                    title,
                    style: .b3,
                    color: .gray10,
                    alignment: .leading
                )

                MText(
                    description,
                    style: .c2,
                    color: .gray5,
                    alignment: .leading
                )
            }

            Spacer()
        }
    }
}
