//
//  ProfileSection.swift
//  MyPage
//
//  Created by 김동준 on 7/17/26.
//

import CommonDomain
import DesignSystem
import Foundation
import SwiftUI

struct ProfileSection: View {
    let imageURL: URL?
    let defaultAvatar: DefaultAvatar
    let userInfo: UserInfo?
    let onProfileButtonTapped: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            profileAvatar

            profileInfo
                .padding(.leading, 14)

            Spacer(minLength: 8)

            profileButton
        }
    }
}

private extension ProfileSection {
    @ViewBuilder
    var profileAvatar: some View {
        if userInfo == nil {
            SkeletonView(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            ProfileAvatarView(
                imageURL: imageURL,
                defaultAvatar: defaultAvatar
            )
        }
    }

    @ViewBuilder
    var profileInfo: some View {
        if let userInfo {
            profileInfoContent(
                nickname: userInfo.nickname,
                daysWithMody: userInfo.daysTogether
            )
        } else {
            VStack(alignment: .leading, spacing: 4) {
                SkeletonView(width: 72, height: 25)
                SkeletonView(width: 128, height: 22)
            }
        }
    }

    func profileInfoContent(
        nickname: String,
        daysWithMody: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            MText(
                "\(nickname)님",
                style: .b3,
                color: .gray10,
                alignment: .leading
            )

            joinedDaysText(daysWithMody: daysWithMody)
        }
    }

    func joinedDaysText(daysWithMody: Int) -> some View {
        (
            Text("모디와 함께한지 ")
                .font(ModyTypography.b7.token.swiftUIFont)
                .foregroundStyle(Color.gray5)
            + Text("\(daysWithMody)일")
                .font(ModyTypography.b5.token.swiftUIFont)
                .foregroundStyle(Color.main0)
            + Text("째")
                .font(ModyTypography.b7.token.swiftUIFont)
                .foregroundStyle(Color.gray5)
        )
        .lineLimit(1)
    }

    var profileButton: some View {
        Button {
            onProfileButtonTapped()
        } label: {
            MText(
                "프로필 변경",
                style: .c1,
                color: .systemWhite,
            )
            .hPadding(12)
            .vPadding(7)
            .background(Color.gray3)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(userInfo == nil)
    }
}
