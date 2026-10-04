//
//  SplashRepositoryTests.swift
//  SplashTests
//
//  Created by 김동준 on 9/29/26.
//

import CommonDomain
import CoreKeyChainStorageInterface
import CoreNetworkInterface
import FirebaseServiceInterface
import SplashTesting
import XCTest
@testable import Splash

final class SplashRepositoryTests: XCTestCase {
    func testHealthCheckRequestsPublicHealthEndpoint() async throws {
        let network = CoreNetworkSpy()
        let repository = makeRepository(network: network)

        let isHealthy = try await repository.getHealthCheck()

        XCTAssertTrue(isHealthy)
        XCTAssertEqual(network.requestedEndpoints.count, 1)
        XCTAssertEqual(network.requestedEndpoints.first?.path, "health")
        XCTAssertEqual(network.requestedEndpoints.first?.method, .GET)
        XCTAssertEqual(network.requestedEndpoints.first?.requiresAuthorization, false)
    }

    func testFetchAndActivateIgnoresFirebaseFailure() async {
        let firebase = FirebaseServiceSpy(fetchError: SplashTestingError.expectedFailure)
        let repository = makeRepository(firebase: firebase)

        await repository.fetchAndActivate()

        XCTAssertEqual(firebase.fetchAndActivateCallCount, 1)
    }

    func testRemoteConfigValuesAreMappedFromFirebase() {
        let notice = NoticePopupInfo(
            title: "공지",
            contents: "내용",
            skipPossible: true
        )
        let firebase = FirebaseServiceSpy(
            strings: [RemoteConfigKeys.appStoreURL.rawValue: "https://apps.apple.com/kr/"],
            bools: [RemoteConfigKeys.forceUpdate.rawValue: true],
            jsonValues: [RemoteConfigKeys.notice.rawValue: notice]
        )
        let repository = makeRepository(firebase: firebase)

        XCTAssertTrue(repository.getRemoteConfigBool(for: .forceUpdate))
        XCTAssertEqual(
            repository.getRemoteConfigString(for: .appStoreURL),
            "https://apps.apple.com/kr/"
        )
        XCTAssertEqual(repository.getNoticePopupInfo(), notice)
    }

    func testStoredAuthSessionIsRestoredWhenAllValuesExist() {
        let keyChain = KeyChainStorageStub(values: [
            KeyChainStorageKey.accessToken.rawValue: "access-token",
            KeyChainStorageKey.refreshToken.rawValue: "refresh-token",
            KeyChainStorageKey.isSignUpDone.rawValue: true,
            KeyChainStorageKey.mainAccessible.rawValue: false,
            KeyChainStorageKey.groupOnboardingCompleted.rawValue: true,
            KeyChainStorageKey.socialLoginType.rawValue: SocialLoginType.apple
        ])
        let repository = makeRepository(keyChain: keyChain)

        XCTAssertEqual(
            repository.getStoredAuthSession(),
            SplashAuthSessionFixture.make(
                id: 0,
                mainAccessible: false,
                socialLoginType: .apple
            )
        )
    }

    func testStoredAuthSessionIsNilWhenARequiredValueIsMissing() {
        let keyChain = KeyChainStorageStub(values: [
            KeyChainStorageKey.accessToken.rawValue: "access-token"
        ])
        let repository = makeRepository(keyChain: keyChain)

        XCTAssertNil(repository.getStoredAuthSession())
    }

    private func makeRepository(
        network: CoreNetworkProtocol = CoreNetworkSpy(),
        firebase: FirebaseServiceInterface = FirebaseServiceSpy(),
        keyChain: CoreKeyChainStorageInterface = KeyChainStorageStub()
    ) -> SplashRepository {
        SplashRepository(
            network: network,
            firebaseService: firebase,
            keyChainStorage: keyChain
        )
    }
}
