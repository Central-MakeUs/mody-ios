//
//  SplashUseCase.swift
//  Splash
//
//  Created by 김동준 on 7/1/26
//

import CommonDomain

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

    public func getChallengeTabHideFlag(key: String) -> Bool {
        splashRepository.getChallengeTabHideFlag(key: key)
    }

    public func getAuthSession() -> AuthSession? {
        splashRepository.getStoredAuthSession()
    }
}
