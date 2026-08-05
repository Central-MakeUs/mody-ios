//
//  ChallengeStreakEmptyView.swift
//  Challenge
//
//  Created by 김동준 on 8/4/26.
//

import DesignSystem
import SwiftUI

struct ChallengeStreakEmptyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image.imgModyStreakEmpty

            VStack(spacing: 4) {
                MText(
                    "아직 함께하는 멤버가 없어요",
                    style: .b3,
                    color: .gray10
                )

                MText(
                    "멤버를 초대하면 연속 기록을 시작할 수 있어요!",
                    style: .b7,
                    color: .gray6
                )
            }
        }
    }
}
