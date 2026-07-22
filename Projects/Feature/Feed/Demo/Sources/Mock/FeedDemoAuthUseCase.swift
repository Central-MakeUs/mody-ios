//
//  FeedDemoAuthUseCase.swift
//  FeedDemo
//
//  Created by 김동준 on 7/22/26.
//

import CommonDomain
import CoreAuthInterface

struct FeedDemoAuthUseCase: AuthUseCaseProtocol {
    func signIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> AuthSession {
        throw CancellationError()
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        try await Task.sleep(nanoseconds: 2_000_000_000)

        return UserInfo(
            memberId: 4537058591744,
            nickname: "다함께빡빡빡",
            profileImageUrl: "",
            daysTogether: 1,
            personalInfoCompleted: true,
            groupOnboardingCompleted: true,
            mainAccessible: true
        )
    }

    func logout() async throws {}

    func deleteAccount() async throws {}
}
