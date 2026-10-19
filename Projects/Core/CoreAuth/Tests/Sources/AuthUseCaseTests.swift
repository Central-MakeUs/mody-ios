//  AuthUseCaseTests.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain
import XCTest
@testable import CoreAuth

final class AuthUseCaseTests: XCTestCase {
    func testSignInForwardsEveryLoginTypeAndTokenAndReturnsSession() async throws {
        for loginType in AuthFixture.loginTypes {
            for token in ["provider-token", "", "한글 +/&?=token"] {
                let repository = AuthRepositorySpy()
                let sut = AuthUseCase(authRepository: repository)

                let result = try await sut.signIn(loginType: loginType, accessToken: token)

                XCTAssertEqual(result, AuthFixture.session)
                XCTAssertEqual(repository.calls, [.signIn(loginType, token)])
            }
        }
    }

    func testGetUserInfoForwardsBothUpdateFlagsAndReturnsUser() async throws {
        for update in [false, true] {
            let repository = AuthRepositorySpy()
            let sut = AuthUseCase(authRepository: repository)

            let result = try await sut.getUserInfo(needUpdateKeyChain: update)

            XCTAssertEqual(result, AuthFixture.user)
            XCTAssertEqual(repository.calls, [.userInfo(update)])
        }
    }

    func testLogoutCallsOnlyPostLogoutOnce() async throws {
        let repository = AuthRepositorySpy()
        try await AuthUseCase(authRepository: repository).logout()
        XCTAssertEqual(repository.calls, [.logout])
    }

    func testDeleteAccountCallsOnlyDeleteAccountOnce() async throws {
        let repository = AuthRepositorySpy()
        try await AuthUseCase(authRepository: repository).deleteAccount()
        XCTAssertEqual(repository.calls, [.deleteAccount])
    }

    func testEveryOperationPropagatesRepositoryErrorAndCancellationWithoutRetry() async {
        let errors: [Error] = [AuthTestError.expected, AuthError.unknown, CancellationError()]
        for error in errors {
            let repository = AuthRepositorySpy()
            repository.error = error
            let sut = AuthUseCase(authRepository: repository)
            let operations: [(AuthRepositorySpy.Call, () async throws -> Void)] = [
                (.signIn(.apple, "token"), { _ = try await sut.signIn(loginType: .apple, accessToken: "token") }),
                (.userInfo(false), { _ = try await sut.getUserInfo(needUpdateKeyChain: false) }),
                (.userInfo(true), { _ = try await sut.getUserInfo(needUpdateKeyChain: true) }),
                (.logout, { try await sut.logout() }),
                (.deleteAccount, { try await sut.deleteAccount() })
            ]
            for (_, operation) in operations {
                await XCTAssertThrowsErrorAsync(operation) {
                    XCTAssertEqual($0 as NSError, error as NSError)
                }
            }
            XCTAssertEqual(repository.calls, operations.map(\.0))
        }
    }
}
