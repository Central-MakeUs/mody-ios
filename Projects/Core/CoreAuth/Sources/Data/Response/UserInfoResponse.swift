//
//  UserInfoResponse.swift
//  CoreAuth
//
//  Created by 김동준 on 7/11/26
//

import CommonDomain

struct UserInfoResponse: Decodable {
    let memberId: Int?
    let nickname: String?
    let profileImageUrl: String?
    let daysTogether: Int?
}

extension UserInfoResponse {
    func toDomain() -> UserInfo {
        UserInfo(
            memberId: memberId ?? -1,
            nickname: nickname ?? "",
            profileImageUrl: profileImageUrl,
            daysTogether: daysTogether ?? 0
        )
    }
}
