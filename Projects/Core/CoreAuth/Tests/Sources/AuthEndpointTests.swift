//  AuthEndpointTests.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain
import CoreNetworkInterface
import XCTest
@testable import CoreAuth

final class AuthEndpointTests: XCTestCase {
    func testSocialSignInUsesProviderPathAndUnauthenticatedGETWithUnmodifiedToken() {
        for (type, path) in [(SocialLoginType.kakao, "KAKAO"), (.apple, "APPLE")] {
            for token in ["token", "", "한글 +/&?=token"] {
                let endpoint = AuthEndpoint.getSignIn(loginType: type, accessToken: token)
                XCTAssertEqual(endpoint.path, "api/v1/oauth/client/\(path)")
                XCTAssertEqual(endpoint.method, .GET)
                XCTAssertEqual(endpoint.queryParameters, ["accessToken": token])
                XCTAssertFalse(endpoint.requiresAuthorization)
                XCTAssertTrue(endpoint.headers.isEmpty)
                XCTAssertNil(endpoint.bodyParameters)
            }
        }
    }

    func testIOSTestLoginOmitsTokenEvenWhenProvided() {
        for token in ["", "must-not-be-sent"] {
            let endpoint = AuthEndpoint.getSignIn(loginType: .iosTest, accessToken: token)
            XCTAssertEqual(endpoint.path, "api/v1/oauth/client/IOSTEST")
            XCTAssertEqual(endpoint.method, .GET)
            XCTAssertTrue(endpoint.queryParameters.isEmpty)
            XCTAssertFalse(endpoint.requiresAuthorization)
            XCTAssertTrue(endpoint.headers.isEmpty)
            XCTAssertNil(endpoint.bodyParameters)
        }
    }

    func testUserInfoUsesAuthenticatedGETWithoutParameters() {
        let endpoint = AuthEndpoint.getUserInfo()
        XCTAssertEqual(endpoint.path, "api/v1/mypage/me")
        XCTAssertEqual(endpoint.method, .GET)
        XCTAssertTrue(endpoint.requiresAuthorization)
        XCTAssertTrue(endpoint.queryParameters.isEmpty)
        XCTAssertTrue(endpoint.headers.isEmpty)
        XCTAssertNil(endpoint.bodyParameters)
    }

    func testLogoutUsesAuthenticatedPOSTWithRefreshTokenBody() throws {
        for token in ["refresh-token", "", "한글 +/&?=token"] {
            let endpoint = AuthEndpoint.postLogout(refreshToken: token)
            XCTAssertEqual(endpoint.path, "api/v1/auth/logout")
            XCTAssertEqual(endpoint.method, .POST)
            XCTAssertTrue(endpoint.requiresAuthorization)
            XCTAssertTrue(endpoint.queryParameters.isEmpty)
            XCTAssertTrue(endpoint.headers.isEmpty)
            let body = try XCTUnwrap(endpoint.bodyParameters)
            let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(body))
            XCTAssertEqual(json as? [String: String], ["refreshToken": token])
        }
    }

    func testDeleteAccountUsesAuthenticatedDELETEWithoutParameters() {
        let endpoint = AuthEndpoint.deleteAccount()
        XCTAssertEqual(endpoint.path, "api/v1/mypage/me")
        XCTAssertEqual(endpoint.method, .DELETE)
        XCTAssertTrue(endpoint.requiresAuthorization)
        XCTAssertTrue(endpoint.queryParameters.isEmpty)
        XCTAssertTrue(endpoint.headers.isEmpty)
        XCTAssertNil(endpoint.bodyParameters)
    }
}
