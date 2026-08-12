//
//  ChallengeDetailGroupOptionalTitleSection.swift
//  Challenge
//
//  Created by 김동준 on 8/10/26.
//

import DesignSystem
import SwiftUI

struct ChallengeDetailGroupOptionalTitleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            groupOptionalChip
            
            VStack(alignment: .leading, spacing: 2) {
                MText(
                    "이번주 주간 챌린지",
                    style: .h3,
                    color: .gray10,
                    alignment: .leading
                )
                
                MText(
                    "원하는 챌린지에 참여해 인증해보세요!",
                    style: .c2,
                    color: .gray7,
                    alignment: .leading
                )
            }
        }
    }
}

private extension ChallengeDetailGroupOptionalTitleSection {
    var groupOptionalChip: some View {
        MText(
            "그룹 선택 챌린지",
            style: .c1,
            color: .gray8
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.main3)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(Color.main0, lineWidth: 1)
        }
    }
}
