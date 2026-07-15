//
//  MainAddGroupAlertView.swift
//  Main
//
//  Created by 김동준 on 7/14/26.
//

import SwiftUI
import DesignSystem

struct MainAddGroupAlertView: View {
    private let onDismiss: () -> Void
    private let onParticipateTap: () -> Void
    private let onCreateTap: () -> Void

    init(
        onDismiss: @escaping () -> Void,
        onParticipateTap: @escaping () -> Void,
        onCreateTap: @escaping () -> Void
    ) {
        self.onDismiss = onDismiss
        self.onParticipateTap = onParticipateTap
        self.onCreateTap = onCreateTap
    }

    var body: some View {
        ZStack {
            Color.systemBlack
                .opacity(0.6)
                .contentShape(Rectangle())
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 12) {
                alertButton(
                    title: "그룹 참여하기",
                    icon: .icUsers,
                    action: onParticipateTap
                )

                alertButton(
                    title: "그룹 생성하기",
                    icon: .icPlus,
                    action: onCreateTap
                )
            }
            .vPadding(24)
            .hPadding(24)
            .greedyWidth()
            .background(Color.systemWhite)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .hPadding(36)
        }
        .ignoresSafeArea()
    }
}

private extension MainAddGroupAlertView {
    func alertButton(
        title: String,
        icon: Image,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.systemWhite)
                    .frame(width: 24, height: 24)

                MText(
                    title,
                    style: .b6,
                    color: .systemWhite
                )
            }
            .hPadding(24)
            .vPadding(13)
            .greedyWidth()
            .background(Color.gray9)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
