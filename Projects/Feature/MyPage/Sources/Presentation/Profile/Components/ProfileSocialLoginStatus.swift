//
//  ProfileSocialLoginStatus.swift
//  MyPage
//
//  Created by 김동준 on 7/19/26.
//

import CommonDomain
import DesignSystem
import SwiftUI

struct ProfileSocialLoginStatus: View {
    private let type: SocialLoginType

    init(type: SocialLoginType) {
        self.type = type
    }

    var body: some View {
        HStack(spacing: 12) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            MText(
                title,
                style: .b6,
                color: foregroundColor
            )
        }
        .vPadding(13)
        .greedyWidth()
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private extension ProfileSocialLoginStatus {
    var icon: Image {
        switch type {
        case .kakao:
            return .icKakao
        case .apple:
            return .icApple
        case .iosTest:
            return .imgModyAppIcon
        }
    }

    var title: String {
        switch type {
        case .kakao:
            return "카카오 계정으로 로그인 중"
        case .apple:
            return "Apple 계정으로 로그인 중"
        case .iosTest:
            return "데모 계정으로 로그인 중"
        }
    }

    var backgroundColor: Color {
        switch type {
        case .kakao:
            return .kakaoBackground
        case .apple:
            return .systemBlack
        case .iosTest:
            return .gray1
        }
    }

    var foregroundColor: Color {
        switch type {
        case .kakao:
            return .systemBlack
        case .apple:
            return .systemWhite
        case .iosTest:
            return .gray10
        }
    }
}
