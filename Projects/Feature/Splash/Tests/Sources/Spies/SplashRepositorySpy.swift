//
//  SplashRepositorySpy.swift
//  SplashTests
//
//  Created by 김동준 on 9/29/26.
//

import CommonDomain
@testable import Splash

final class SplashRepositorySpy: SplashRepositoryProtocol {
    private let healthCheckResult: Result<Bool, Error>
    private let remoteConfigBools: [RemoteConfigKeys: Bool]
    private let remoteConfigStrings: [RemoteConfigKeys: String]
    private let notice: NoticePopupInfo?
    private let authSession: AuthSession?

    private(set) var fetchAndActivateCallCount = 0
    private(set) var healthCheckCallCount = 0

    init(
        healthCheckResult: Result<Bool, Error> = .success(true),
        remoteConfigBools: [RemoteConfigKeys: Bool] = [:],
        remoteConfigStrings: [RemoteConfigKeys: String] = [:],
        notice: NoticePopupInfo? = nil,
        authSession: AuthSession? = nil
    ) {
        self.healthCheckResult = healthCheckResult
        self.remoteConfigBools = remoteConfigBools
        self.remoteConfigStrings = remoteConfigStrings
        self.notice = notice
        self.authSession = authSession
    }

    func getHealthCheck() async throws -> Bool {
        healthCheckCallCount += 1
        return try healthCheckResult.get()
    }

    func fetchAndActivate() async {
        fetchAndActivateCallCount += 1
    }

    func getRemoteConfigBool(for key: RemoteConfigKeys) -> Bool {
        remoteConfigBools[key, default: false]
    }

    func getRemoteConfigString(for key: RemoteConfigKeys) -> String {
        remoteConfigStrings[key, default: ""]
    }

    func getNoticePopupInfo() -> NoticePopupInfo? {
        notice
    }

    func getStoredAuthSession() -> AuthSession? {
        authSession
    }
}
