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

    public init(
        memberId: Int,
        nickname: String,
        profileImageUrl: String?,
        daysTogether: Int
    ) {
        self.memberId = memberId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.daysTogether = daysTogether
    }
}
