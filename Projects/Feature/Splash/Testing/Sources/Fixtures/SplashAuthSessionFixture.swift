//
//  SplashAuthSessionFixture.swift
//  SplashTesting
//
//  Created by 김동준 on 9/29/26.
//

import CommonDomain

public enum SplashAuthSessionFixture {
    public static func make(
        id: Int = 1,
        accessToken: String = "access-token",
        refreshToken: String = "refresh-token",
        personalInfoCompleted: Bool = true,
        mainAccessible: Bool = true,
        groupOnboardingCompleted: Bool = true,
        socialLoginType: SocialLoginType? = .kakao
    ) -> AuthSession {
        AuthSession(
            id: id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            personalInfoCompleted: personalInfoCompleted,
            mainAccessible: mainAccessible,
            groupOnboardingCompleted: groupOnboardingCompleted,
            socialLoginType: socialLoginType
        )
    }
}
