//
//  UserInfo.swift
//  CommonDomain
//
//  Created by 김동준 on 7/11/26
//

public struct UserInfo: Equatable {
    public let memberId: Int
    public let nickname: String
    public let profileImageUrl: String?
    public let daysTogether: Int
    public let personalInfoCompleted: Bool
    public let groupOnboardingCompleted: Bool
    public let mainAccessible: Bool

    public init(
        memberId: Int,
        nickname: String,
        profileImageUrl: String?,
        daysTogether: Int,
        personalInfoCompleted: Bool,
        groupOnboardingCompleted: Bool,
        mainAccessible: Bool
    ) {
        self.memberId = memberId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.daysTogether = daysTogether
        self.personalInfoCompleted = personalInfoCompleted
        self.groupOnboardingCompleted = groupOnboardingCompleted
        self.mainAccessible = mainAccessible
    }
}
