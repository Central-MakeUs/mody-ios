//
//  MyPageDetailContent.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import DesignSystem
import SwiftUI

struct MyPageDetailContent: View {
    let title: String
    let onBackTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MNavigationBar(
                title: title,
                onBackTap: onBackTap
            )

            Spacer()

            MText(
                "\(title) 화면",
                style: .b4,
                color: .gray5
            )

            Spacer()
        }
        .background(Color.systemWhite)
    }
}
