//
//  SocialLoginResponse.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import CommonDomain

struct SocialLoginResponse: Decodable {
    let id: Int?
    let accessToken: String?
    let refreshToken: String?
    let personalInfoCompleted: Bool?
    let mainAccessible: Bool?
    let groupOnboardingCompleted: Bool?
}

extension SocialLoginResponse {
    func toDomain() -> AuthSession {
        AuthSession(
            id: id ?? -1,
            accessToken: accessToken ?? "",
            refreshToken: refreshToken ?? "",
            personalInfoCompleted: personalInfoCompleted ?? false,
            mainAccessible: mainAccessible ?? false,
            groupOnboardingCompleted: groupOnboardingCompleted ?? false
        )
    }
}
