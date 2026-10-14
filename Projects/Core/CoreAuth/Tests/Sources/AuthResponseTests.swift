//  AuthResponseTests.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain
import XCTest
@testable import CoreAuth

final class AuthResponseTests: XCTestCase {
    func testSignInDecodesAndMapsEveryField() throws {
        let response = try decode(SocialLoginResponse.self, json: AuthFixture.sessionJSON)
        XCTAssertEqual(response.toDomain(), AuthFixture.session)
        XCTAssertNil(response.toDomain().socialLoginType)
    }

    func testUserInfoDecodesAndMapsEveryField() throws {
        let response = try decode(UserInfoResponse.self, json: AuthFixture.userJSON)
        XCTAssertEqual(response.toDomain(), AuthFixture.user)
    }

    func testSignInMissingAndNullFieldsUseDefaultsIndependently() throws {
        let full = try object(AuthFixture.sessionJSON)
        let defaults: [String: Any] = [
            "id": -1, "accessToken": "", "refreshToken": "",
            "personalInfoCompleted": false, "mainAccessible": false, "groupOnboardingCompleted": false
        ]
        for key in full.keys {
            for useNull in [false, true] {
                var input = full
                if useNull { input[key] = NSNull() } else { input.removeValue(forKey: key) }
                let actual = try decode(SocialLoginResponse.self, object: input).toDomain()
                var expected = full
                expected[key] = defaults[key]
                XCTAssertEqual(actual, session(expected), "field=\(key), null=\(useNull)")
            }
        }
        XCTAssertEqual(try decode(SocialLoginResponse.self, json: "{}").toDomain(), session(defaults))
        XCTAssertEqual(try decode(SocialLoginResponse.self, object: full.mapValues { _ in NSNull() }).toDomain(), session(defaults))
    }

    func testUserInfoMissingAndNullFieldsUseDefaultsIndependently() throws {
        let full = try object(AuthFixture.userJSON)
        let defaults: [String: Any] = [
            "memberId": -1, "nickname": "", "profileImageUrl": NSNull(), "daysTogether": 0,
            "personalInfoCompleted": false, "groupOnboardingCompleted": false, "mainAccessible": false
        ]
        for key in full.keys {
            for useNull in [false, true] {
                var input = full
                if useNull { input[key] = NSNull() } else { input.removeValue(forKey: key) }
                let actual = try decode(UserInfoResponse.self, object: input).toDomain()
                var expected = full
                expected[key] = defaults[key]
                XCTAssertEqual(actual, user(expected), "field=\(key), null=\(useNull)")
            }
        }
        XCTAssertEqual(try decode(UserInfoResponse.self, json: "{}").toDomain(), user(defaults))
        XCTAssertEqual(try decode(UserInfoResponse.self, object: full.mapValues { _ in NSNull() }).toDomain(), user(defaults))
    }

    func testEveryBooleanCombinationMapsWithoutChangingFlags() throws {
        for personal in [false, true] {
            for main in [false, true] {
                for group in [false, true] {
                    let flags: [String: Bool] = [
                        "personalInfoCompleted": personal, "mainAccessible": main,
                        "groupOnboardingCompleted": group
                    ]
                    let session = try decode(SocialLoginResponse.self, object: flags).toDomain()
                    let user = try decode(UserInfoResponse.self, object: flags).toDomain()
                    XCTAssertEqual(session.personalInfoCompleted, personal)
                    XCTAssertEqual(session.mainAccessible, main)
                    XCTAssertEqual(session.groupOnboardingCompleted, group)
                    XCTAssertEqual(user.personalInfoCompleted, personal)
                    XCTAssertEqual(user.mainAccessible, main)
                    XCTAssertEqual(user.groupOnboardingCompleted, group)
                }
            }
        }
    }

    func testSignInPreservesZeroNegativeIDsAndEmptyTokens() throws {
        for id in [0, -7, Int.max] {
            let response = try decode(SocialLoginResponse.self, object: [
                "id": id, "accessToken": "", "refreshToken": "한글 토큰"
            ])
            XCTAssertEqual(response.toDomain().id, id)
            XCTAssertEqual(response.toDomain().accessToken, "")
            XCTAssertEqual(response.toDomain().refreshToken, "한글 토큰")
        }
    }

    func testUserInfoPreservesBoundaryNumbersEmptyStringsAndUnvalidatedImageURL() throws {
        for number in [0, -7, Int.max] {
            let response = try decode(UserInfoResponse.self, object: [
                "memberId": number, "daysTogether": number, "nickname": "", "profileImageUrl": "not a URL"
            ])
            let result = response.toDomain()
            XCTAssertEqual(result.memberId, number)
            XCTAssertEqual(result.daysTogether, number)
            XCTAssertEqual(result.nickname, "")
            XCTAssertEqual(result.profileImageUrl, "not a URL")
        }
        XCTAssertEqual(try decode(UserInfoResponse.self, json: "{\"profileImageUrl\":\"\"}").toDomain().profileImageUrl, "")
    }

    func testSignInRejectsWrongTypeForEveryField() throws {
        for key in try object(AuthFixture.sessionJSON).keys {
            XCTAssertThrowsError(try decode(SocialLoginResponse.self, object: [key: ["invalid"]])) {
                guard case DecodingError.typeMismatch = $0 else { return XCTFail("Unexpected error: \($0)") }
            }
        }
    }

    func testUserInfoRejectsWrongTypeForEveryField() throws {
        for key in try object(AuthFixture.userJSON).keys {
            XCTAssertThrowsError(try decode(UserInfoResponse.self, object: [key: ["invalid"]])) {
                guard case DecodingError.typeMismatch = $0 else { return XCTFail("Unexpected error: \($0)") }
            }
        }
    }

    func testUnknownFieldsDoNotChangeDomainMapping() throws {
        var signIn = try object(AuthFixture.sessionJSON)
        signIn["futureField"] = ["nested": true]
        var userInfo = try object(AuthFixture.userJSON)
        userInfo["futureField"] = 100
        XCTAssertEqual(try decode(SocialLoginResponse.self, object: signIn).toDomain(), AuthFixture.session)
        XCTAssertEqual(try decode(UserInfoResponse.self, object: userInfo).toDomain(), AuthFixture.user)
    }

    private func decode<T: Decodable>(_ type: T.Type, json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    private func decode<T: Decodable>(_ type: T.Type, object: [String: Any]) throws -> T {
        try JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: object))
    }

    private func object(_ json: String) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any])
    }

    private func session(_ fields: [String: Any]) -> AuthSession {
        AuthSession(
            id: fields["id"] as! Int, accessToken: fields["accessToken"] as! String,
            refreshToken: fields["refreshToken"] as! String,
            personalInfoCompleted: fields["personalInfoCompleted"] as! Bool,
            mainAccessible: fields["mainAccessible"] as! Bool,
            groupOnboardingCompleted: fields["groupOnboardingCompleted"] as! Bool
        )
    }

    private func user(_ fields: [String: Any]) -> UserInfo {
        UserInfo(
            memberId: fields["memberId"] as! Int, nickname: fields["nickname"] as! String,
            profileImageUrl: fields["profileImageUrl"] as? String, daysTogether: fields["daysTogether"] as! Int,
            personalInfoCompleted: fields["personalInfoCompleted"] as! Bool,
            groupOnboardingCompleted: fields["groupOnboardingCompleted"] as! Bool,
            mainAccessible: fields["mainAccessible"] as! Bool
        )
    }
}
