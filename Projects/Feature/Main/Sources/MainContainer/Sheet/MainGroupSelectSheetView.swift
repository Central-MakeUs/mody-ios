//
//  MainGroupSelectSheetView.swift
//  Main
//
//  Created by 김동준 on 7/6/26.
//

import SwiftUI
import DesignSystem

struct MainGroupSelectSheetView: View {
    private let onParticipateTap: () -> Void
    private let onCreateTap: () -> Void

    init(
        onParticipateTap: @escaping () -> Void,
        onCreateTap: @escaping () -> Void
    ) {
        self.onParticipateTap = onParticipateTap
        self.onCreateTap = onCreateTap
    }

    var body: some View {
        VStack(spacing: 12) {
            menuButton(
                title: "그룹 참여하기",
                backgroundColor: .main,
                textColor: .gray10,
                action: onParticipateTap
            )

            menuButton(
                title: "그룹 생성하기",
                backgroundColor: .gray10,
                textColor: .systemWhite,
                action: onCreateTap
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 32)
        .background(Color.systemWhite)
    }
}

private extension MainGroupSelectSheetView {
    func menuButton(
        title: String,
        backgroundColor: Color,
        textColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            MText(
                title,
                style: .b6,
                color: textColor
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
