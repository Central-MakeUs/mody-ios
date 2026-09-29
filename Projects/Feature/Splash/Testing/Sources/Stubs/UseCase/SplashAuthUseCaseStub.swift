//
//  SplashAuthUseCaseStub.swift
//  SplashTesting
//
//  Created by 김동준 on 9/29/26.
//

import CommonDomain
import CoreAuthInterface

public struct SplashAuthUseCaseStub: AuthUseCaseProtocol {
    private let userInfoResult: Result<UserInfo, Error>
    private let responseDelay: Duration

    public init(
        userInfoResult: Result<UserInfo, Error>,
        responseDelay: Duration = .zero
    ) {
        self.userInfoResult = userInfoResult
        self.responseDelay = responseDelay
    }

    public func signIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession {
        throw SplashTestingError.unsupported
    }

    public func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        if responseDelay > .zero {
            try await Task.sleep(for: responseDelay)
        }

        return try userInfoResult.get()
    }

    public func logout() async throws {}
    public func deleteAccount() async throws {}
}

public enum SplashTestingError: Error {
    case expectedFailure
    case unsupported
}
