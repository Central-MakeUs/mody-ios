//
//  SignInUserInfoFixture.swift
//  SignInTesting
//
//  Created by 김동준 on 10/1/26.
//

import CommonDomain

public enum SignInUserInfoFixture {
    public static func make(nickname: String = "모디") -> UserInfo {
        UserInfo(
            memberId: 1,
            nickname: nickname,
            profileImageUrl: nil,
            daysTogether: 0,
            personalInfoCompleted: true,
            groupOnboardingCompleted: true,
            mainAccessible: true
        )
    }
}
