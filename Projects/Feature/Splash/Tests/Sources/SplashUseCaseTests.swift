//
//  SplashUseCaseTests.swift
//  SplashTests
//
//  Created by 김동준 on 9/29/26.
//

import CommonDomain
import CoreAuthTesting
import XCTest
@testable import Splash

final class SplashUseCaseTests: XCTestCase {
    func testNeedsMinimumVersionUpdateWhenCurrentVersionIsLower() {
        let useCase = makeUseCase()
        let cases = [
            (current: "0.9.9", minimum: "1.0.0"),
            (current: "1.6.999", minimum: "1.7.0"),
            (current: "1.07.282", minimum: "1.07.283"),
            (current: "1.1102.2", minimum: "1.1102.3")
        ]

        for testCase in cases {
            XCTAssertTrue(
                useCase.needsMinimumVersionUpdate(
                    currentVersion: testCase.current,
                    targetVersion: testCase.minimum
                )
            )
        }
    }

    func testDoesNotNeedMinimumVersionUpdateWhenCurrentVersionMeetsMinimum() {
        let useCase = makeUseCase()
        let cases = [
            (current: "1.0.0", minimum: "1.0.0"),
            (current: "2.0.0", minimum: "1.9999.9999"),
            (current: "1.8.0", minimum: "1.07.283"),
            (current: "1.1102.3", minimum: "1.1102.2")
        ]

        for testCase in cases {
            XCTAssertFalse(
                useCase.needsMinimumVersionUpdate(
                    currentVersion: testCase.current,
                    targetVersion: testCase.minimum
                )
            )
        }
    }

    func testDoesNotNeedMinimumVersionUpdateForInvalidVersion() {
        let useCase = makeUseCase()
        let cases: [(current: String?, minimum: String)] = [
            (nil, "1.0.0"),
            ("1.0", "1.0.0"),
            ("1.0.0", "invalid"),
            ("1.-1.0", "1.0.0"),
            ("1.0.0.0", "1.0.0")
        ]

        for testCase in cases {
            XCTAssertFalse(
                useCase.needsMinimumVersionUpdate(
                    currentVersion: testCase.current,
                    targetVersion: testCase.minimum
                )
            )
        }
    }

    func testForwardsRepositoryValues() async throws {
        let session = AuthSessionFixture.make(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            socialLoginType: .kakao
        )
        let notice = NoticePopupInfo(
            title: "공지",
            contents: "내용",
            skipPossible: true
        )
        let repository = SplashRepositorySpy(
            healthCheckResult: .success(true),
            remoteConfigBools: [.forceUpdate: true],
            remoteConfigStrings: [.appStoreURL: "https://apps.apple.com/kr/"],
            notice: notice,
            authSession: session
        )
        let useCase = SplashUseCase(splashRepository: repository)

        await useCase.fetchAndActivate()
        let isHealthy = try await useCase.getHealthCheck()

        XCTAssertTrue(isHealthy)
        XCTAssertTrue(useCase.getRemoteConfigBool(for: .forceUpdate))
        XCTAssertEqual(
            useCase.getRemoteConfigString(for: .appStoreURL),
            "https://apps.apple.com/kr/"
        )
        XCTAssertEqual(useCase.getNoticePopupInfo(), notice)
        XCTAssertEqual(useCase.getAuthSession(), session)
        XCTAssertEqual(repository.fetchAndActivateCallCount, 1)
        XCTAssertEqual(repository.healthCheckCallCount, 1)
    }

    private func makeUseCase() -> SplashUseCase {
        SplashUseCase(splashRepository: SplashRepositorySpy())
    }
}
