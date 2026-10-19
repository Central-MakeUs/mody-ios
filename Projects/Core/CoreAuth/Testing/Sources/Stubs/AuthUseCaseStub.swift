//
//  AuthUseCaseStub.swift
//  CoreAuthTesting
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain
import CoreAuthInterface

public struct AuthUseCaseStub: AuthUseCaseProtocol {
    private let signInHandler: (SocialLoginType, String) async throws -> AuthSession
    private let userInfoHandler: (Bool) async throws -> UserInfo
    private let logoutHandler: () async throws -> Void
    private let deleteAccountHandler: () async throws -> Void
    private let responseDelay: Duration

    public init(
        signInResult: Result<AuthSession, Error> = .failure(CoreAuthStubError.unexpectedCall("signIn")),
        userInfoResult: Result<UserInfo, Error> = .failure(CoreAuthStubError.unexpectedCall("getUserInfo")),
        logoutResult: Result<Void, Error> = .failure(CoreAuthStubError.unexpectedCall("logout")),
        deleteAccountResult: Result<Void, Error> = .failure(CoreAuthStubError.unexpectedCall("deleteAccount")),
        responseDelay: Duration = .zero
    ) {
        self.init(
            signIn: { _, _ in try signInResult.get() },
            getUserInfo: { _ in try userInfoResult.get() },
            logout: { try logoutResult.get() },
            deleteAccount: { try deleteAccountResult.get() },
            responseDelay: responseDelay
        )
    }

    public init(
        signIn: @escaping (SocialLoginType, String) async throws -> AuthSession = { _, _ in
            throw CoreAuthStubError.unexpectedCall("signIn")
        },
        getUserInfo: @escaping (Bool) async throws -> UserInfo,
        logout: @escaping () async throws -> Void = {
            throw CoreAuthStubError.unexpectedCall("logout")
        },
        deleteAccount: @escaping () async throws -> Void = {
            throw CoreAuthStubError.unexpectedCall("deleteAccount")
        },
        responseDelay: Duration = .zero
    ) {
        self.signInHandler = signIn
        self.userInfoHandler = getUserInfo
        self.logoutHandler = logout
        self.deleteAccountHandler = deleteAccount
        self.responseDelay = responseDelay
    }

    public func signIn(loginType: SocialLoginType, accessToken: String) async throws -> AuthSession {
        try await delayResponse()
        return try await signInHandler(loginType, accessToken)
    }

    public func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        try await delayResponse()
        return try await userInfoHandler(needUpdateKeyChain)
    }

    public func logout() async throws {
        try await delayResponse()
        try await logoutHandler()
    }

    public func deleteAccount() async throws {
        try await delayResponse()
        try await deleteAccountHandler()
    }

    private func delayResponse() async throws {
        if responseDelay > .zero {
            try await Task.sleep(for: responseDelay)
        }
    }
}
