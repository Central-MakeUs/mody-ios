//
//  FeedDemoAuthUseCaseStub.swift
//  FeedDemo
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreAuthInterface
import Foundation

struct FeedDemoAuthUseCaseStub: AuthUseCaseProtocol {
    func signIn(loginType: SocialLoginType, accessToken: String) async throws -> AuthSession {
        try await Task.sleep(for: .milliseconds(500))
        throw CancellationError()
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        try await Task.sleep(for: .milliseconds(500))
        return UserInfo(
            memberId: 100,
            nickname: "내 기록",
            profileImageUrl: "",
            daysTogether: 1,
            personalInfoCompleted: true,
            groupOnboardingCompleted: true,
            mainAccessible: true
        )
    }

    func logout() async throws {
        try await Task.sleep(for: .milliseconds(500))
    }

    func deleteAccount() async throws {
        try await Task.sleep(for: .milliseconds(500))
    }
}
