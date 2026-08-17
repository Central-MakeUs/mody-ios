//
//  ChallengeTabBar.swift
//  Challenge
//
//  Created by 김동준 on 8/1/26.
//

import SwiftUI
import DesignSystem

struct ChallengeTabBar: View {
    @Binding var selection: ChallengeFeature.State.Tab

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.systemWhite

            Rectangle()
                .fill(Color.gray2)
                .frame(height: 2)

            HStack(spacing: 0) {
                ForEach(ChallengeFeature.State.Tab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
        }
        .frame(height: 52)
    }
}

private extension ChallengeTabBar {
    func tabButton(for tab: ChallengeFeature.State.Tab) -> some View {
        Button {
            selection = tab
        } label: {
            MText(
                tab.rawValue,
                style: .b3,
                color: selection == tab ? .gray10 : .gray5
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .overlay(alignment: .bottom) {
            if selection == tab {
                Rectangle()
                    .fill(Color.gray10)
                    .frame(height: 2)
            }
        }
    }
}
