//
//  AuthUseCaseProtocol.swift
//  CoreAuthInterface
//
//  Created by 김동준 on 7/2/26
//

import CommonDomain

public protocol AuthUseCaseProtocol {
    func signIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession
}
