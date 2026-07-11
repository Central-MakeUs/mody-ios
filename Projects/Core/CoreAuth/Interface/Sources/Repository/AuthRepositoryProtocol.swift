//
//  AuthRepositoryProtocol.swift
//  CoreAuthInterface
//
//  Created by 김동준 on 7/2/26
//

import CommonDomain

public protocol AuthRepositoryProtocol {
    func getSignIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo

    func postLogout() async throws
}
