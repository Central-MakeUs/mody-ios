//
//  AuthUseCase.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import CommonDomain
import CoreAuthInterface

public struct AuthUseCase: AuthUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func signIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession {
        try await authRepository.getSignIn(
            loginType: loginType,
            accessToken: accessToken
        )
    }

    public func getUserInfo() async throws -> UserInfo {
        try await authRepository.getUserInfo()
    }

    public func logout() async throws {
        try await authRepository.postLogout()
    }
}
