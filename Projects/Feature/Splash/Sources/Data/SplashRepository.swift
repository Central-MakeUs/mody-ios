//
//  SplashRepository.swift
//  Splash
//
//  Created by 김동준 on 7/1/26
//

import CommonDomain
import CoreKeyChainStorageInterface
import CoreNetworkInterface
import FirebaseServiceInterface

public struct SplashRepository: SplashRepositoryProtocol {
    private let network: CoreNetworkProtocol
    private let firebaseService: FirebaseServiceInterface
    private let keyChainStorage: CoreKeyChainStorageInterface

    public init(
        network: CoreNetworkProtocol,
        firebaseService: FirebaseServiceInterface,
        keyChainStorage: CoreKeyChainStorageInterface
    ) {
        self.network = network
        self.firebaseService = firebaseService
        self.keyChainStorage = keyChainStorage
    }

    public func getHealthCheck() async throws -> Bool {
        let endpoint = SplashEndpoint.getHealthCheck()
        let _: CoreNetworkResponse<[String: String]> = try await network.request(endpoint)

        return true
    }

    public func fetchAndActivate() async {
        try? await firebaseService.fetchAndActivate()
    }

    public func getRemoteConfigBool(for key: RemoteConfigKeys) -> Bool {
        firebaseService.getBool(forKey: key.rawValue)
    }

    public func getRemoteConfigString(for key: RemoteConfigKeys) -> String {
        firebaseService.getString(forKey: key.rawValue)
    }

    public func getNoticePopupInfo() -> NoticePopupInfo? {
        firebaseService.getJson(
            forKey: RemoteConfigKeys.notice.rawValue,
            as: NoticePopupInfo.self
        )
    }

    public func getStoredAuthSession() -> AuthSession? {
        do {
            let accessToken: String = try keyChainStorage.read(
                key: KeyChainStorageKey.accessToken.rawValue
            )
            let refreshToken: String = try keyChainStorage.read(
                key: KeyChainStorageKey.refreshToken.rawValue
            )
            let personalInfoCompleted: Bool = try keyChainStorage.read(
                key: KeyChainStorageKey.isSignUpDone.rawValue
            )
            let mainAccessible: Bool = try keyChainStorage.read(
                key: KeyChainStorageKey.mainAccessible.rawValue
            )
            let groupOnboardingCompleted: Bool = try keyChainStorage.read(
                key: KeyChainStorageKey.groupOnboardingCompleted.rawValue
            )
            let socialLoginType: SocialLoginType = try keyChainStorage.read(
                key: KeyChainStorageKey.socialLoginType.rawValue
            )

            return AuthSession(
                id: 0,
                accessToken: accessToken,
                refreshToken: refreshToken,
                personalInfoCompleted: personalInfoCompleted,
                mainAccessible: mainAccessible,
                groupOnboardingCompleted: groupOnboardingCompleted,
                socialLoginType: socialLoginType
            )
        } catch {
            return nil
        }
    }
}
