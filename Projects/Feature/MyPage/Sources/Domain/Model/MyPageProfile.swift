//
//  MyPageProfile.swift
//  MyPage
//
//  Created by 김동준 on 7/16/26.
//

import CommonDomain

public struct MyPageProfile: Equatable {
    public let socialLoginType: SocialLoginType
    public let name: String
    public let birthDate: String

    public init(
        socialLoginType: SocialLoginType,
        name: String,
        birthDate: String
    ) {
        self.socialLoginType = socialLoginType
        self.name = name
        self.birthDate = birthDate
    }
}
