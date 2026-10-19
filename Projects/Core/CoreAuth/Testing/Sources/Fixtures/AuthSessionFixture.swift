//
//  AuthSessionFixture.swift
//  CoreAuthTesting
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain

public enum AuthSessionFixture {
    public static func make(
        id: Int = 1,
        accessToken: String = "demo-access-token",
        refreshToken: String = "demo-refresh-token",
        personalInfoCompleted: Bool = true,
        mainAccessible: Bool = true,
        groupOnboardingCompleted: Bool = true,
        socialLoginType: SocialLoginType? = nil
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
