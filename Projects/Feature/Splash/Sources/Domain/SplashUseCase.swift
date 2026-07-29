//
//  SplashUseCase.swift
//  Splash
//
//  Created by 김동준 on 7/1/26
//

import CommonDomain
import Foundation

public struct SplashUseCase {
    private let splashRepository: SplashRepositoryProtocol

    public init(splashRepository: SplashRepositoryProtocol) {
        self.splashRepository = splashRepository
    }

    public func getHealthCheck() async throws -> Bool {
        try await splashRepository.getHealthCheck()
    }

    public func fetchAndActivate() async {
        await splashRepository.fetchAndActivate()
    }

    public func getRemoteConfigBool(for key: RemoteConfigKeys) -> Bool {
        splashRepository.getRemoteConfigBool(for: key)
    }

    public func getRemoteConfigString(for key: RemoteConfigKeys) -> String {
        splashRepository.getRemoteConfigString(for: key)
    }

    public func getNoticePopupInfo() -> NoticePopupInfo? {
        splashRepository.getNoticePopupInfo()
    }

    public func getAuthSession() -> AuthSession? {
        splashRepository.getStoredAuthSession()
    }
}

public extension SplashUseCase {
    func needsMinimumVersionUpdate(
        currentVersion: String?,
        targetVersion: String
    ) -> Bool {
        guard let currentVersion,
              let currentComponents = versionComponents(from: currentVersion),
              let targetComponents = versionComponents(from: targetVersion) else {
            return false
        }

        for (current, target) in zip(currentComponents, targetComponents) {
            guard current != target else { continue }
            return current < target
        }

        return false
    }
}

private extension SplashUseCase {
    func versionComponents(from version: String) -> [Int]? {
        let components = version
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ".", omittingEmptySubsequences: false)

        guard components.count == 3 else { return nil }

        let numbers = components.compactMap { Int($0) }
        guard numbers.count == components.count,
              numbers.allSatisfy({ $0 >= 0 }) else {
            return nil
        }

        return numbers
    }
}
