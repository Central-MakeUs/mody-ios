//
//  SignInAuthSessionFixture.swift
//  SignInTesting
//
//  Created by 김동준 on 10/1/26.
//

import CommonDomain

public enum SignInAuthSessionFixture {
    public static func make(
        personalInfoCompleted: Bool = true,
        mainAccessible: Bool = true,
        groupOnboardingCompleted: Bool = true
    ) -> AuthSession {
        AuthSession(
            id: 1,
            accessToken: "demo-access-token",
            refreshToken: "demo-refresh-token",
            personalInfoCompleted: personalInfoCompleted,
            mainAccessible: mainAccessible,
            groupOnboardingCompleted: groupOnboardingCompleted
        )
    }
}
