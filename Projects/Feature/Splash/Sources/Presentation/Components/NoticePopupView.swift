//
//  NoticePopupView.swift
//  Splash
//

import DesignSystem
import SwiftUI

struct NoticePopupView: View {
    private let info: NoticePopupInfo
    private let action: () -> Void

    init(
        info: NoticePopupInfo,
        action: @escaping () -> Void
    ) {
        self.info = info
        self.action = action
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                MText(
                    info.title ?? "-",
                    style: .b2,
                    color: .gray10,
                    lineLimit: nil
                )
                .greedyWidth()

                ScrollView {
                    MText(
                        info.contents ?? "-",
                        style: .c2,
                        color: .gray9,
                        lineLimit: nil,
                        alignment: .leading
                    )
                    .greedyWidth(.leading)
                }
                .frame(maxHeight: 380)
            }
            .padding(.horizontal, 18)
            .padding(.top, 28)
            .padding(.bottom, 20)

            MButton(
                "확인",
                style: isConfirmationEnabled ? .primary : .gray,
                isDisabled: !isConfirmationEnabled,
                horizontalPadding: 0,
                verticalPadding: 10,
                maxWidth: .infinity,
                action: action
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .background(Color.systemWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .hPadding(36)
    }

    private var isConfirmationEnabled: Bool {
        info.skipPossible ?? false
    }
}
