//
//  ChallengeEmptyView.swift
//  Challenge
//
//  Created by 김동준 on 8/6/26.
//

import DesignSystem
import SwiftUI

struct ChallengeEmptyView: View {
    private let isStreakEmpty: Bool
    
    init(isStreakEmpty: Bool) {
        self.isStreakEmpty = isStreakEmpty
    }
    
    var body: some View {
        VStack(spacing: 12) {
            image

            VStack(spacing: 4) {
                MText(
                    "아직 함께하는 멤버가 없어요",
                    style: .b3,
                    color: .gray10
                )

                MText(
                    description,
                    style: .b7,
                    color: .gray6
                )
            }
        }
    }
    
    private var image: Image {
        isStreakEmpty
        ? Image.imgModyStreakEmpty
        : Image.imgModyChallengeEmpty
    }
    
    private var description: String {
        isStreakEmpty
        ? "멤버를 초대하면 연속 기록을 시작할 수 있어요!"
        : "멤버를 초대하면 챌린지를 시작할 수 있어요!"
    }
}
