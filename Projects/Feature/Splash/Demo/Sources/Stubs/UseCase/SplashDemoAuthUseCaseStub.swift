//
//  SplashDemoAuthUseCaseStub.swift
//  SplashDemo
//
//  Created by 김동준 on 9/29/26.
//

import CommonDomain
import CoreAuthInterface

struct SplashDemoAuthUseCaseStub: AuthUseCaseProtocol {
    private let scenario: SplashScenario

    init(scenario: SplashScenario) {
        self.scenario = scenario
    }

    func signIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession {
        throw SplashDemoAuthUseCaseStubError.unsupported
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        try await Task.sleep(for: .milliseconds(700))

        guard let userInfo = scenario.userInfo else {
            throw SplashDemoAuthUseCaseStubError.signedOut
        }

        return userInfo
    }

    func logout() async throws {}

    func deleteAccount() async throws {}
}

private enum SplashDemoAuthUseCaseStubError: Error {
    case signedOut
    case unsupported
}
