//
//  SplashDemoRepositoryStub.swift
//  SplashDemo
//
//  Created by 김동준 on 8/21/26.
//

import CommonDomain
import CoreNetworkInterface
import FirebaseServiceInterface
import Splash

struct SplashDemoRepositoryStub: SplashRepositoryProtocol {
    private let scenario: SplashScenario
    private let network: CoreNetworkProtocol
    private let firebaseService: FirebaseServiceInterface

    init(
        scenario: SplashScenario,
        network: CoreNetworkProtocol,
        firebaseService: FirebaseServiceInterface
    ) {
        self.scenario = scenario
        self.network = network
        self.firebaseService = firebaseService
    }

    func getHealthCheck() async throws -> Bool {
        let _: CoreNetworkResponse<[String: String]> = try await network.request(
            CoreNetworkEndpoint(path: "health", requiresAuthorization: false)
        )
        return scenario != .serverUnstable
    }

    func fetchAndActivate() async {
        try? await firebaseService.fetchAndActivate()
    }

    func getRemoteConfigBool(for key: RemoteConfigKeys) -> Bool {
        firebaseService.getBool(forKey: key.rawValue)
    }

    func getRemoteConfigString(for key: RemoteConfigKeys) -> String {
        firebaseService.getString(forKey: key.rawValue)
    }

    func getNoticePopupInfo() -> NoticePopupInfo? {
        firebaseService.getJson(forKey: RemoteConfigKeys.notice.rawValue, as: NoticePopupInfo.self)
    }

    func getStoredAuthSession() -> AuthSession? {
        nil
    }
}
