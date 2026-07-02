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
    private let keyChainStorage: CoreKeyChainStorageInterface

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
        try saveAuthSessionInfoToKeyChain(session)

        return session
    }
}

private extension AuthRepository {
    func saveAuthSessionInfoToKeyChain(_ session: AuthSession) throws {
        try? keyChainStorage.save(
            key: KeyChainStorageKey.isSignUpDone.rawValue,
            value: session.personalInfoCompleted
        )

        try? keyChainStorage.save(
            key: KeyChainStorageKey.accessToken.rawValue,
            value: session.accessToken
        )

        try? keyChainStorage.save(
            key: KeyChainStorageKey.refreshToken.rawValue,
            value: session.refreshToken
        )
    }
}
