//
//  AuthRepository+KeyChain.swift
//  CoreAuth
//
//  Created by 김동준 on 7/7/26
//

import CommonDomain
import CoreKeyChainStorageInterface

extension AuthRepository {
    private var authSessionStorageKeys: [KeyChainStorageKey] {
        [
            .accessToken,
            .refreshToken,
            .isSignUpDone,
            .mainAccessible,
            .groupOnboardingCompleted
        ]
    }

    func readRefreshTokenFromKeyChain() throws -> String {
        try keyChainStorage.read(
            key: KeyChainStorageKey.refreshToken.rawValue
        )
    }

    func saveAuthSessionInfoToKeyChain(_ session: AuthSession) throws {
        try? keyChainStorage.save(
            key: KeyChainStorageKey.isSignUpDone.rawValue,
            value: session.personalInfoCompleted
        )

        try? keyChainStorage.save(
            key: KeyChainStorageKey.mainAccessible.rawValue,
            value: session.mainAccessible
        )

        try? keyChainStorage.save(
            key: KeyChainStorageKey.groupOnboardingCompleted.rawValue,
            value: session.groupOnboardingCompleted
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

    func deleteAuthSessionInfoFromKeyChain() throws {
        authSessionStorageKeys.forEach {
            try? keyChainStorage.delete(key: $0.rawValue)
        }
    }
}
