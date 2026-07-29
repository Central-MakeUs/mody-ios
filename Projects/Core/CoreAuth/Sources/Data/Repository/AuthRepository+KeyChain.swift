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
            .groupOnboardingCompleted,
            .socialLoginType
        ]
    }

    func readRefreshTokenFromKeyChain() throws -> String {
        try keyChainStorage.read(
            key: KeyChainStorageKey.refreshToken.rawValue
        )
    }

    func saveAuthSessionInfoToKeyChain(
        _ session: AuthSession,
        _ loginType: SocialLoginType
    ) throws {
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

        try? keyChainStorage.save(
            key: KeyChainStorageKey.socialLoginType.rawValue,
            value: loginType
        )
    }

    func updateAuthSessionStatusToKeyChain(_ response: UserInfoResponse) throws {
        guard let personalInfoCompleted = response.personalInfoCompleted,
              let mainAccessible = response.mainAccessible,
              let groupOnboardingCompleted = response.groupOnboardingCompleted else { return }
        try keyChainStorage.save(
            key: KeyChainStorageKey.isSignUpDone.rawValue,
            value: personalInfoCompleted
        )

        try keyChainStorage.save(
            key: KeyChainStorageKey.mainAccessible.rawValue,
            value: mainAccessible
        )

        try keyChainStorage.save(
            key: KeyChainStorageKey.groupOnboardingCompleted.rawValue,
            value: groupOnboardingCompleted
        )
    }

    func deleteAuthSessionInfoFromKeyChain() throws {
        authSessionStorageKeys.forEach {
            try? keyChainStorage.delete(key: $0.rawValue)
        }
    }
    
    func deleteFCMTokenFromKeyChain() throws {
        try? keyChainStorage.delete(key: KeyChainStorageKey.fcmToken.rawValue)
    }
}
