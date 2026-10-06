//  ChallengeAuthUseCaseStub.swift
//  ChallengeTesting
//
//  Created by 김동준 on 10/6/26.
//

import CommonDomain
import CoreAuthInterface
import Foundation

public struct ChallengeAuthUseCaseStub: AuthUseCaseProtocol {
    private let userInfoResult: Result<UserInfo, NetworkError>
    private let responseDelay: Duration?

    public init(
        userInfoResult: Result<UserInfo, NetworkError>,
        responseDelay: Duration? = nil
    ) {
        self.userInfoResult = userInfoResult
        self.responseDelay = responseDelay
    }

    public func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        if let responseDelay { try await Task.sleep(for: responseDelay) }
        return try userInfoResult.get()
    }

    public func signIn(loginType: SocialLoginType, accessToken: String) async throws -> AuthSession {
        throw NetworkError.unknown
    }

    public func logout() async throws { throw NetworkError.unknown }
    public func deleteAccount() async throws { throw NetworkError.unknown }
}
