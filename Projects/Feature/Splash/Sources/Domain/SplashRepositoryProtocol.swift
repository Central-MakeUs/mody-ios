//
//  SplashRepositoryProtocol.swift
//  Splash
//
//  Created by 김동준 on 7/1/26
//

import CommonDomain

public protocol SplashRepositoryProtocol {
    func getHealthCheck() async throws -> Bool
    func fetchAndActivate() async
    func getChallengeTabHideFlag(key: String) -> Bool
    func getStoredAuthSession() -> AuthSession?
}
