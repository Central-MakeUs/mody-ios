//  AuthRepositorySpy.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain
import CoreAuthInterface

final class AuthRepositorySpy: AuthRepositoryProtocol {
    enum Call: Equatable {
        case signIn(SocialLoginType, String)
        case userInfo(Bool)
        case logout
        case deleteAccount
    }

    var error: Error?
    private(set) var calls: [Call] = []

    func getSignIn(loginType: SocialLoginType, accessToken: String) async throws -> AuthSession {
        calls.append(.signIn(loginType, accessToken))
        if let error { throw error }
        return AuthFixture.session
    }

    func getUserInfo(needUpdateKeyChain: Bool) async throws -> UserInfo {
        calls.append(.userInfo(needUpdateKeyChain))
        if let error { throw error }
        return AuthFixture.user
    }

    func postLogout() async throws {
        calls.append(.logout)
        if let error { throw error }
    }

    func deleteAccount() async throws {
        calls.append(.deleteAccount)
        if let error { throw error }
    }
}
