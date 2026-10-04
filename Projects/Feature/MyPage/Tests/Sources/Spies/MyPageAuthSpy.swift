//
//  MyPageAuthSpy.swift
//  MyPageTests
//
//  Created by 김동준 on 10/5/26.
//

import CommonDomain
import CoreAuthInterface

final class MyPageAuthSpy: AuthUseCaseProtocol {
    var userResult: Result<UserInfo, Error> = .success(MyPageFixture.user)
    var error: Error?
    private(set) var userRequests: [Bool] = []
    private(set) var logoutCount = 0
    private(set) var deleteCount = 0

    func signIn(loginType: SocialLoginType, accessToken: String) async throws -> AuthSession {
        throw CancellationError()
    }
    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        userRequests.append(needUpdateKeyChain)
        return try userResult.get()
    }
    func logout() async throws {
        logoutCount += 1
        if let error { throw error }
    }
    func deleteAccount() async throws {
        deleteCount += 1
        if let error { throw error }
    }
}
