//
//  UserInfoFixture.swift
//  CoreAuthTesting
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain

public enum UserInfoFixture {
    public static func make(
        memberId: Int = 1,
        nickname: String = "모디",
        profileImageUrl: String? = nil,
        daysTogether: Int = 0,
        personalInfoCompleted: Bool = true,
        groupOnboardingCompleted: Bool = true,
        mainAccessible: Bool = true
    ) -> UserInfo {
        UserInfo(
            memberId: memberId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            daysTogether: daysTogether,
            personalInfoCompleted: personalInfoCompleted,
            groupOnboardingCompleted: groupOnboardingCompleted,
            mainAccessible: mainAccessible
        )
    }
}
