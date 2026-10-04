//
//  SplashUserInfoFixture.swift
//  SplashTesting
//
//  Created by 김동준 on 9/29/26.
//

import CommonDomain

public enum SplashUserInfoFixture {
    public static func make(
        memberID: Int = 1,
        nickname: String = "모디",
        personalInfoCompleted: Bool = true,
        groupOnboardingCompleted: Bool = true,
        mainAccessible: Bool = true
    ) -> UserInfo {
        UserInfo(
            memberId: memberID,
            nickname: nickname,
            profileImageUrl: nil,
            daysTogether: 0,
            personalInfoCompleted: personalInfoCompleted,
            groupOnboardingCompleted: groupOnboardingCompleted,
            mainAccessible: mainAccessible
        )
    }
}
