//
//  SignInAuthUseCaseStub.swift
//  SignInTesting
//
//  Created by 김동준 on 10/1/26.
//

import CommonDomain
import CoreAuthInterface

public struct SignInAuthUseCaseStub: AuthUseCaseProtocol {
    private let signInResult: Result<AuthSession, Error>
    private let userInfoResult: Result<UserInfo, Error>
    private let responseDelay: Duration

    public init(
        signInResult: Result<AuthSession, Error>,
        userInfoResult: Result<UserInfo, Error>,
        responseDelay: Duration = .zero
    ) {
        self.signInResult = signInResult
        self.userInfoResult = userInfoResult
        self.responseDelay = responseDelay
    }

    public func signIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession {
        if responseDelay > .zero {
            try await Task.sleep(for: responseDelay)
        }
        return try signInResult.get()
    }

    public func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        return try userInfoResult.get()
    }

    public func logout() async throws {}
    public func deleteAccount() async throws {}
}
