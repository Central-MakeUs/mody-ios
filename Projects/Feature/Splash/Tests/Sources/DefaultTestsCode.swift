import CommonDomain
import XCTest
@testable import Splash

final class SplashTests: XCTestCase {
    func testNeedsMinimumVersionUpdateWhenCurrentVersionIsBelowMinimumVersion() {
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
                ),
                "Expected \(testCase.current) to be below \(testCase.minimum)"
            )
        }
    }

    func testDoesNotNeedMinimumVersionUpdateWhenCurrentVersionMeetsMinimumVersion() {
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
                ),
                "Expected \(testCase.current) to meet \(testCase.minimum)"
            )
        }
    }

    func testDoesNotNeedMinimumVersionUpdateForInvalidVersion() {
        let useCase = makeUseCase()

        XCTAssertFalse(
            useCase.needsMinimumVersionUpdate(
                currentVersion: nil,
                targetVersion: "1.0.0"
            )
        )
        XCTAssertFalse(
            useCase.needsMinimumVersionUpdate(
                currentVersion: "1.0",
                targetVersion: "1.0.0"
            )
        )
        XCTAssertFalse(
            useCase.needsMinimumVersionUpdate(
                currentVersion: "1.0.0",
                targetVersion: "invalid"
            )
        )
    }

    private func makeUseCase() -> SplashUseCase {
        SplashUseCase(splashRepository: SplashRepositoryStub())
    }
}

private struct SplashRepositoryStub: SplashRepositoryProtocol {
    func getHealthCheck() async throws -> Bool { true }
    func fetchAndActivate() async {}
    func getRemoteConfigBool(for key: RemoteConfigKeys) -> Bool { false }
    func getRemoteConfigString(for key: RemoteConfigKeys) -> String { "" }
    func getNoticePopupInfo() -> NoticePopupInfo? { nil }
    func getStoredAuthSession() -> AuthSession? { nil }
}
