//  AuthServiceTests.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain
import XCTest
@testable import CoreAuth

final class AuthServiceTests: XCTestCase {
    func testSignInRequestsEveryProviderAndReturnsDecodedResponse() async throws {
        for loginType in AuthFixture.loginTypes {
            let network = AuthNetworkSpy(responseJSON: AuthFixture.response(AuthFixture.sessionJSON))
            let result = try await AuthService(network: network).getSignIn(loginType: loginType, accessToken: "token")

            XCTAssertEqual(result.toDomain(), AuthFixture.session)
            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertEqual(network.endpoints.first?.path, "api/v1/oauth/client/\(loginType.rawValue)")
            XCTAssertEqual(network.endpoints.first?.queryParameters, loginType == .iosTest ? [:] : ["accessToken": "token"])
        }
    }

    func testUserInfoRequestsCorrectEndpointAndReturnsDecodedResponse() async throws {
        let network = AuthNetworkSpy(responseJSON: AuthFixture.response(AuthFixture.userJSON))
        let result = try await AuthService(network: network).getUserInfo()
        XCTAssertEqual(result.toDomain(), AuthFixture.user)
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/mypage/me")
        XCTAssertEqual(network.endpoints.first?.method, .GET)
    }

    func testMissingAndNullSignInResultThrowUnknown() async {
        for json in ["{}", "{\"result\":null}"] {
            let network = AuthNetworkSpy(responseJSON: json)
            await XCTAssertThrowsErrorAsync({
                try await AuthService(network: network).getSignIn(loginType: .kakao, accessToken: "token")
            }) { XCTAssertEqual($0 as? AuthError, .unknown) }
            XCTAssertEqual(network.endpoints.count, 1)
        }
    }

    func testMissingAndNullUserInfoResultThrowUnknown() async {
        for json in ["{}", "{\"result\":null}"] {
            let network = AuthNetworkSpy(responseJSON: json)
            await XCTAssertThrowsErrorAsync({ try await AuthService(network: network).getUserInfo() }) {
                XCTAssertEqual($0 as? AuthError, .unknown)
            }
            XCTAssertEqual(network.endpoints.count, 1)
        }
    }

    func testEmptyResultObjectIsAcceptedForSignInAndUserInfo() async throws {
        let network = AuthNetworkSpy(responseJSON: AuthFixture.response("{}"))
        let sut = AuthService(network: network)
        let session = try await sut.getSignIn(loginType: .apple, accessToken: "")
        let user = try await sut.getUserInfo()
        XCTAssertEqual(session.toDomain().id, -1)
        XCTAssertEqual(user.toDomain().memberId, -1)
        XCTAssertEqual(network.endpoints.count, 2)
    }

    func testLogoutAcceptsAbsentNullAndEmptyResultsAndSendsRefreshToken() async throws {
        for json in ["{}", "{\"result\":null}", AuthFixture.response("{}")] {
            let network = AuthNetworkSpy(responseJSON: json)
            try await AuthService(network: network).postLogout(refreshToken: "refresh")
            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertEqual(network.endpoints.first?.path, "api/v1/auth/logout")
            XCTAssertEqual(network.endpoints.first?.method, .POST)
            XCTAssertEqual(network.endpoints.first?.bodyParameters as? [String: String], ["refreshToken": "refresh"])
        }
    }

    func testDeleteAccountAcceptsAbsentNullAndEmptyResults() async throws {
        for json in ["{}", "{\"result\":null}", AuthFixture.response("{}")] {
            let network = AuthNetworkSpy(responseJSON: json)
            try await AuthService(network: network).deleteAccount()
            XCTAssertEqual(network.endpoints.count, 1)
            XCTAssertEqual(network.endpoints.first?.path, "api/v1/mypage/me")
            XCTAssertEqual(network.endpoints.first?.method, .DELETE)
        }
    }

    func testAllRequestsPropagateNetworkErrorAndCancellationWithoutRetry() async {
        for error in [AuthTestError.expected as Error, CancellationError()] {
            let network = AuthNetworkSpy()
            network.error = error
            for operation in operations(AuthService(network: network)) {
                await XCTAssertThrowsErrorAsync(operation) { XCTAssertEqual($0 as NSError, error as NSError) }
            }
            XCTAssertEqual(network.endpoints.count, 4)
        }
    }

    func testAllRequestsPropagateDecodingFailure() async {
        let network = AuthNetworkSpy(responseJSON: "invalid JSON")
        for operation in operations(AuthService(network: network)) {
            await XCTAssertThrowsErrorAsync(operation) { XCTAssertTrue($0 is DecodingError) }
        }
        XCTAssertEqual(network.endpoints.count, 4)
    }

    private func operations(_ sut: AuthService) -> [() async throws -> Void] {
        [
            { _ = try await sut.getSignIn(loginType: .kakao, accessToken: "token") },
            { _ = try await sut.getUserInfo() },
            { try await sut.postLogout(refreshToken: "refresh") },
            { try await sut.deleteAccount() }
        ]
    }
}
