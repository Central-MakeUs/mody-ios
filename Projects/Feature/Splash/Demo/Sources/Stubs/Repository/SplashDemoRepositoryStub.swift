//
//  SplashDemoRepositoryStub.swift
//  SplashDemo
//
//  Created by 김동준 on 8/21/26.
//

import CommonDomain
import Splash

struct SplashDemoRepositoryStub: SplashRepositoryProtocol {
    private let scenario: SplashScenario

    init(scenario: SplashScenario) {
        self.scenario = scenario
    }

    func getHealthCheck() async throws -> Bool {
        switch scenario {
        case .serverUnstable:
            false
        case .healthCheckFailure:
            throw SplashDemoRepositoryError.healthCheckFailed
        default:
            true
        }
    }

    func fetchAndActivate() async {
        await waitForConfiguredDelay()
    }

    func getRemoteConfigBool(for key: RemoteConfigKeys) -> Bool {
        switch key {
        case .forceUpdate:
            scenario == .forceUpdate
        case .guestLogin,
             .notice,
             .minimumSupportedVersion,
             .appStoreURL:
            false
        }
    }

    func getRemoteConfigString(for key: RemoteConfigKeys) -> String {
        switch key {
        case .minimumSupportedVersion:
            scenario == .minimumSupportedVersion ? "99.0.0" : "0.0.0"
        case .appStoreURL:
            "https://apps.apple.com/kr/"
        case .forceUpdate,
             .guestLogin,
             .notice:
            ""
        }
    }

    func getNoticePopupInfo() -> NoticePopupInfo? {
        scenario.notice
    }

    func getStoredAuthSession() -> AuthSession? {
        nil
    }

    private func waitForConfiguredDelay() async {
        try? await Task.sleep(
            for: .milliseconds(700)
        )
    }
}

private enum SplashDemoRepositoryError: Error {
    case healthCheckFailed
}
