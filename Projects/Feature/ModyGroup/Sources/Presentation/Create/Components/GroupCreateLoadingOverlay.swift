//
//  GroupCreateLoadingOverlay.swift
//  ModyGroup
//
//  Created by 김동준 on 8/18/26.
//

import DesignSystem
import SwiftUI

struct GroupCreateLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.systemBlack
                .opacity(0.6)
                .ignoresSafeArea()

            loadingCard
        }
        .greedyFrame()
    }
}

private extension GroupCreateLoadingOverlay {
    var loadingCard: some View {
        VStack(spacing: 0) {
            MLottieView(.loadingWithCharacter)
                .frame(width: 100, height: 100)
                .padding(.top, 32)

            MText(
                "그룹 생성 중..",
                style: .b2,
                color: .gray10
            )
            .padding(.top, 19)

            MText(
                "잠시만 기다려주세요\n그룹을 생성하는 중이에요!",
                style: .c2,
                color: .gray6,
                lineLimit: 2
            )
            .padding(.top, 8)
            .padding(.bottom, 34)
        }
        .width(260)
        .background(Color.systemWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
