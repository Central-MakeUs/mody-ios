//
//  AuthRepository.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import CommonDomain
import CoreAuthInterface
import CoreKeyChainStorageInterface

public struct AuthRepository: AuthRepositoryProtocol {
    private let authService: AuthService
    let keyChainStorage: CoreKeyChainStorageInterface

    public init(
        authService: AuthService,
        keyChainStorage: CoreKeyChainStorageInterface
    ) {
        self.authService = authService
        self.keyChainStorage = keyChainStorage
    }

    public func getSignIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession {
        let response = try await authService.getSignIn(
            loginType: loginType,
            accessToken: accessToken
        )

        let session = response.toDomain()
        try saveAuthSessionInfoToKeyChain(session, loginType)

        return session
    }

    public func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        let response = try await authService.getUserInfo()
        if needUpdateKeyChain {
            try updateAuthSessionStatusToKeyChain(response)
        }

        return response.toDomain()
    }

    public func postLogout() async throws {
        let refreshToken = try readRefreshTokenFromKeyChain()

        try await authService.postLogout(refreshToken: refreshToken)
        try deleteAuthSessionInfoFromKeyChain()
        try deleteFCMTokenFromKeyChain()
    }

    public func deleteAccount() async throws {
        try await authService.deleteAccount()
        try deleteAuthSessionInfoFromKeyChain()
        try deleteFCMTokenFromKeyChain()
    }
}
