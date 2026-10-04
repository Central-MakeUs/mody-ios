//
//  SignInAuthUseCaseSpy.swift
//  SignInTests
//
//  Created by 김동준 on 10/4/26.
//

import CommonDomain
import CoreAuthInterface
import SignInTesting

final class SignInAuthUseCaseSpy: AuthUseCaseProtocol {
    private(set) var signInRequests: [(loginType: SocialLoginType, accessToken: String)] = []

    func signIn(loginType: SocialLoginType, accessToken: String) async throws -> AuthSession {
        signInRequests.append((loginType, accessToken))
        return SignInAuthSessionFixture.make()
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        SignInUserInfoFixture.make()
    }

    func logout() async throws {}

    func deleteAccount() async throws {}
}
