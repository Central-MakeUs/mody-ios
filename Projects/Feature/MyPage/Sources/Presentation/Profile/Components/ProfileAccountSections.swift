//
//  ProfileAccountSections.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

import DesignSystem
import SwiftUI

struct ProfileAccountSections: View {
    private let onLogout: () -> Void
    private let onDeleteAccount: () -> Void

    init(
        onLogout: @escaping () -> Void,
        onDeleteAccount: @escaping () -> Void
    ) {
        self.onLogout = onLogout
        self.onDeleteAccount = onDeleteAccount
    }

    var body: some View {
        VStack(spacing: 0) {
            accountActionRow(
                title: "로그아웃",
                color: .gray9,
                hasDivider: true,
                action: onLogout
            )

            accountActionRow(
                title: "탈퇴하기",
                color: .systemError,
                hasDivider: false,
                action: onDeleteAccount
            )
        }
    }
}

private extension ProfileAccountSections {
    func accountActionRow(
        title: String,
        color: Color,
        hasDivider: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            MText(
                title,
                style: .b4,
                color: color,
                alignment: .leading
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .overlay(alignment: .bottom) {
                if hasDivider {
                    Color.gray1
                        .frame(height: 1)
                }
            }
            .contentShape(Rectangle())
        }
    }
}
