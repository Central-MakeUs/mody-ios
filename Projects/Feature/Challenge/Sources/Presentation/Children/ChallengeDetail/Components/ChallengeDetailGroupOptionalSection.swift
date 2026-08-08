//
//  ChallengeDetailGroupOptionalSection.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import DesignSystem
import SwiftUI

struct ChallengeDetailGroupOptionalSection: View {
    var body: some View {
        MText(
            "그룹 선택 챌린지",
            style: .b3,
            color: .gray10,
            alignment: .leading
        )
        .greedyWidth(.leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(Color.gray00)
    }
}
