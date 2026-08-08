//
//  ChallengeDetailGroupRequiredSection.swift
//  Challenge
//
//  Created by 김동준 on 8/8/26.
//

import DesignSystem
import SwiftUI

struct ChallengeDetailGroupRequiredSection: View {
    var body: some View {
        MText(
            "그룹 필수 챌린지",
            style: .b3,
            color: .gray10,
            alignment: .leading
        )
        .greedyWidth(.leading)
        .padding(24)
        .background(Color.systemWhite)
    }
}
