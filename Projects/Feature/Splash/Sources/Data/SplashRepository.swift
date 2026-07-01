//
//  SplashRepository.swift
//  Splash
//
//  Created by 김동준 on 7/1/26
//

import FirebaseServiceInterface

public struct SplashRepository: SplashRepositoryProtocol {
    private let firebaseService: FirebaseServiceInterface

    public init(firebaseService: FirebaseServiceInterface) {
        self.firebaseService = firebaseService
    }

    public func getHealthCheck() async -> Bool {
        // TODO: 추후 API 연결
        true
    }

    public func fetchAndActivate() async {
        try? await firebaseService.fetchAndActivate()
    }

    public func getChallengeTabHideFlag(key: String) -> Bool {
        firebaseService.getBool(forKey: key)
    }
}
