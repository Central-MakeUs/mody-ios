//  AuthRepositoryTests.swift
//  CoreAuthTests
//
//  Created by 김동준 on 10/8/26.
//

import CommonDomain
import XCTest
@testable import CoreAuth

final class AuthRepositoryTests: XCTestCase {
    private let statusKeys = ["isSignUpDone", "mainAccessible", "groupOnboardingCompleted"]
    private let sessionKeys = [
        "isSignUpDone", "mainAccessible", "groupOnboardingCompleted",
        "accessToken", "refreshToken", "socialLoginType"
    ]

    func testSignInMapsAndSavesEveryProviderAndStatusCombinationAfterNetworkSuccess() async throws {
        for loginType in AuthFixture.loginTypes {
            for mask in 0..<8 {
                let personal = mask & 1 != 0
                let main = mask & 2 != 0
                let group = mask & 4 != 0
                let network = AuthNetworkSpy(responseJSON: AuthFixture.response("""
                {"id":42,"accessToken":"new-access","refreshToken":"new-refresh",
                 "personalInfoCompleted":\(personal),"mainAccessible":\(main),"groupOnboardingCompleted":\(group)}
                """))
                let storage = AuthKeyChainSpy()
                storage.values = ["accessToken": "old-access", "refreshToken": "old-refresh", "fcmToken": "keep-fcm", "unrelated": "keep"]
                network.onRequest = { _ in XCTAssertTrue(storage.savedKeys.isEmpty) }
                let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

                let result = try await sut.getSignIn(loginType: loginType, accessToken: "provider-token")

                XCTAssertEqual(result, AuthSession(
                    id: 42, accessToken: "new-access", refreshToken: "new-refresh",
                    personalInfoCompleted: personal, mainAccessible: main, groupOnboardingCompleted: group
                ))
                XCTAssertEqual(storage.savedKeys, sessionKeys)
                XCTAssertEqual(storage.values["isSignUpDone"] as? Bool, personal)
                XCTAssertEqual(storage.values["mainAccessible"] as? Bool, main)
                XCTAssertEqual(storage.values["groupOnboardingCompleted"] as? Bool, group)
                XCTAssertEqual(storage.values["accessToken"] as? String, "new-access")
                XCTAssertEqual(storage.values["refreshToken"] as? String, "new-refresh")
                XCTAssertEqual(storage.values["socialLoginType"] as? SocialLoginType, loginType)
                XCTAssertEqual(storage.values["fcmToken"] as? String, "keep-fcm")
                XCTAssertEqual(storage.values["unrelated"] as? String, "keep")
                XCTAssertTrue(storage.readKeys.isEmpty)
                XCTAssertTrue(storage.deletedKeys.isEmpty)
                XCTAssertTrue(storage.updatedKeys.isEmpty)
                XCTAssertEqual(network.endpoints.count, 1)
            }
        }
    }

    func testSignInWithEmptyResponseObjectSavesDefaultSession() async throws {
        let network = AuthNetworkSpy(responseJSON: AuthFixture.response("{}"))
        let storage = AuthKeyChainSpy()
        let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

        let result = try await sut.getSignIn(loginType: .iosTest, accessToken: "")

        XCTAssertEqual(result, AuthSession(
            id: -1, accessToken: "", refreshToken: "", personalInfoCompleted: false,
            mainAccessible: false, groupOnboardingCompleted: false
        ))
        XCTAssertEqual(storage.savedKeys, sessionKeys)
        XCTAssertEqual(storage.values["accessToken"] as? String, "")
        XCTAssertEqual(storage.values["refreshToken"] as? String, "")
        for key in statusKeys { XCTAssertEqual(storage.values[key] as? Bool, false) }
        XCTAssertEqual(storage.values["socialLoginType"] as? SocialLoginType, .iosTest)
    }

    func testSignInIgnoresEveryCombinationOfSaveFailuresAndAttemptsAllSixWrites() async throws {
        // 6개 저장 키의 성공/실패 조합 64개. 기존 try? 계약을 검증한다.
        for mask in 0..<64 {
            let network = AuthNetworkSpy(responseJSON: AuthFixture.response(AuthFixture.sessionJSON))
            let storage = AuthKeyChainSpy()
            storage.failingSaveKeys = Set(sessionKeys.enumerated().compactMap { mask & (1 << $0.offset) != 0 ? $0.element : nil })
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

            let result = try await sut.getSignIn(loginType: .apple, accessToken: "provider")

            XCTAssertEqual(result, AuthFixture.session, "failure mask=\(mask)")
            XCTAssertEqual(storage.savedKeys, sessionKeys)
            XCTAssertEqual(Set(storage.values.keys), Set(sessionKeys).subtracting(storage.failingSaveKeys))
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertEqual(network.endpoints.count, 1)
        }
    }

    func testSignInNetworkErrorAndCancellationLeaveExistingStorageUntouched() async {
        for error in [AuthTestError.expected as Error, CancellationError()] {
            let network = AuthNetworkSpy()
            network.error = error
            let storage = AuthKeyChainSpy()
            storage.values = ["accessToken": "existing"]
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

            await XCTAssertThrowsErrorAsync({ try await sut.getSignIn(loginType: .apple, accessToken: "provider") }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertTrue(storage.savedKeys.isEmpty)
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertEqual(storage.values["accessToken"] as? String, "existing")
            XCTAssertEqual(network.endpoints.count, 1)
        }
    }

    func testSignInMissingResultAndMalformedResponseDoNotWriteStorage() async {
        for json in ["{}", "{\"result\":null}", "{\"result\":{\"id\":\"invalid\"}}"] {
            let network = AuthNetworkSpy(responseJSON: json)
            let storage = AuthKeyChainSpy()
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)
            await XCTAssertThrowsErrorAsync({ try await sut.getSignIn(loginType: .kakao, accessToken: "provider") }) {
                XCTAssertTrue($0 is AuthError || $0 is DecodingError)
            }
            XCTAssertTrue(storage.savedKeys.isEmpty)
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertEqual(network.endpoints.count, 1)
        }
    }

    func testUserInfoUpdatesOnlyWhenRequestedAndAllThreeStatusesArePresent() async throws {
        // 각 상태의 nil/false/true 27개 × 갱신 여부 2개.
        let flags: [Bool?] = [nil, false, true]
        for update in [false, true] {
            for personal in flags {
                for main in flags {
                    for group in flags {
                        let json = """
                        {"memberId":42,"nickname":"모디","daysTogether":17,
                         "personalInfoCompleted":\(jsonValue(personal)),"mainAccessible":\(jsonValue(main)),
                         "groupOnboardingCompleted":\(jsonValue(group))}
                        """
                        let network = AuthNetworkSpy(responseJSON: AuthFixture.response(json))
                        let storage = AuthKeyChainSpy()
                        storage.values = ["accessToken": "keep-access", "refreshToken": "keep-refresh", "fcmToken": "keep-fcm", "socialLoginType": SocialLoginType.kakao]
                        network.onRequest = { _ in XCTAssertTrue(storage.savedKeys.isEmpty) }
                        let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

                        let result = try await sut.getUserInfo(needUpdateKeyChain: update)

                        XCTAssertEqual(result, UserInfo(
                            memberId: 42, nickname: "모디", profileImageUrl: nil, daysTogether: 17,
                            personalInfoCompleted: personal ?? false,
                            groupOnboardingCompleted: group ?? false, mainAccessible: main ?? false
                        ))
                        if update, let personal, let main, let group {
                            XCTAssertEqual(storage.savedKeys, statusKeys)
                            XCTAssertEqual(storage.values["isSignUpDone"] as? Bool, personal)
                            XCTAssertEqual(storage.values["mainAccessible"] as? Bool, main)
                            XCTAssertEqual(storage.values["groupOnboardingCompleted"] as? Bool, group)
                        } else {
                            XCTAssertTrue(storage.savedKeys.isEmpty)
                        }
                        XCTAssertEqual(storage.values["accessToken"] as? String, "keep-access")
                        XCTAssertEqual(storage.values["refreshToken"] as? String, "keep-refresh")
                        XCTAssertEqual(storage.values["fcmToken"] as? String, "keep-fcm")
                        XCTAssertEqual(storage.values["socialLoginType"] as? SocialLoginType, .kakao)
                        XCTAssertTrue(storage.readKeys.isEmpty)
                        XCTAssertTrue(storage.deletedKeys.isEmpty)
                        XCTAssertTrue(storage.updatedKeys.isEmpty)
                        XCTAssertEqual(network.endpoints.count, 1)
                    }
                }
            }
        }
    }

    func testUserInfoMapsFullResponseAndPreservesExistingStatusesWhenUpdateIsDisabled() async throws {
        let network = AuthNetworkSpy(responseJSON: AuthFixture.response(AuthFixture.userJSON))
        let storage = AuthKeyChainSpy()
        storage.values = ["isSignUpDone": false, "mainAccessible": false, "groupOnboardingCompleted": true]
        storage.failingSaveKeys = Set(statusKeys)
        let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

        let result = try await sut.getUserInfo(needUpdateKeyChain: false)

        XCTAssertEqual(result, AuthFixture.user)
        XCTAssertTrue(storage.savedKeys.isEmpty)
        XCTAssertEqual(storage.values["isSignUpDone"] as? Bool, false)
        XCTAssertEqual(storage.values["mainAccessible"] as? Bool, false)
        XCTAssertEqual(storage.values["groupOnboardingCompleted"] as? Bool, true)
    }

    func testUserInfoEmptyResultObjectPreservesExistingStatuses() async throws {
        let network = AuthNetworkSpy(responseJSON: AuthFixture.response("{}"))
        let storage = AuthKeyChainSpy()
        storage.values = Dictionary(uniqueKeysWithValues: statusKeys.map { ($0, true) })
        let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

        let result = try await sut.getUserInfo(needUpdateKeyChain: true)

        XCTAssertEqual(result.memberId, -1)
        XCTAssertTrue(storage.savedKeys.isEmpty)
        for key in statusKeys { XCTAssertEqual(storage.values[key] as? Bool, true) }
    }

    func testUserInfoStopsAtFirstFailedStatusWriteAndKeepsEarlierWrites() async {
        for mask in 1..<8 {
            let network = AuthNetworkSpy(responseJSON: AuthFixture.response(AuthFixture.userJSON))
            let storage = AuthKeyChainSpy()
            storage.failingSaveKeys = Set(statusKeys.enumerated().compactMap { mask & (1 << $0.offset) != 0 ? $0.element : nil })
            let firstFailure = statusKeys.firstIndex { storage.failingSaveKeys.contains($0) }!
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)

            await XCTAssertThrowsErrorAsync({ try await sut.getUserInfo(needUpdateKeyChain: true) }) {
                XCTAssertEqual($0 as? AuthTestError, .expected)
            }

            XCTAssertEqual(storage.savedKeys, Array(statusKeys.prefix(firstFailure + 1)))
            XCTAssertEqual(Set(storage.values.keys), Set(statusKeys.prefix(firstFailure)))
            XCTAssertTrue(storage.deletedKeys.isEmpty)
            XCTAssertEqual(network.endpoints.count, 1)
        }
    }

    func testUserInfoNetworkErrorAndCancellationDoNotMutateStorage() async {
        for update in [false, true] {
            for error in [AuthTestError.expected as Error, CancellationError()] {
                let network = AuthNetworkSpy()
                network.error = error
                let storage = AuthKeyChainSpy()
                storage.values = ["isSignUpDone": true]
                let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)
                await XCTAssertThrowsErrorAsync({ try await sut.getUserInfo(needUpdateKeyChain: update) }) {
                    XCTAssertEqual($0 as NSError, error as NSError)
                }
                XCTAssertTrue(storage.savedKeys.isEmpty)
                XCTAssertTrue(storage.deletedKeys.isEmpty)
                XCTAssertEqual(storage.values["isSignUpDone"] as? Bool, true)
                XCTAssertEqual(network.endpoints.count, 1)
            }
        }
    }

    func testUserInfoMissingResultAndMalformedResponseDoNotWriteStorage() async {
        for json in ["{}", "{\"result\":null}", "{\"result\":{\"mainAccessible\":\"invalid\"}}"] {
            let network = AuthNetworkSpy(responseJSON: json)
            let storage = AuthKeyChainSpy()
            let sut = AuthRepository(authService: AuthService(network: network), keyChainStorage: storage)
            await XCTAssertThrowsErrorAsync({ try await sut.getUserInfo(needUpdateKeyChain: true) }) {
                XCTAssertTrue($0 is AuthError || $0 is DecodingError)
            }
            XCTAssertTrue(storage.savedKeys.isEmpty)
            XCTAssertEqual(network.endpoints.count, 1)
        }
    }

    private func jsonValue(_ flag: Bool?) -> String {
        flag.map { String($0) } ?? "null"
    }
}
