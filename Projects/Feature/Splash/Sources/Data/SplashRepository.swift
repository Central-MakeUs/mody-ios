//
//  SplashRepository.swift
//  Splash
//
//  Created by 김동준 on 7/1/26
//

import CoreNetworkInterface
import FirebaseServiceInterface

public struct SplashRepository: SplashRepositoryProtocol {
    private let network: CoreNetworkProtocol
    private let firebaseService: FirebaseServiceInterface

    public init(
        network: CoreNetworkProtocol,
        firebaseService: FirebaseServiceInterface
    ) {
        self.network = network
        self.firebaseService = firebaseService
    }

    public func getHealthCheck() async throws -> Bool {
        let endpoint = SplashEndpoint.getHealthCheck()
        let _: CoreNetworkResponse<[String: String]> = try await network.request(endpoint)

        return true
    }

    public func fetchAndActivate() async {
        try? await firebaseService.fetchAndActivate()
    }

    public func getChallengeTabHideFlag(key: String) -> Bool {
        firebaseService.getBool(forKey: key)
    }
}
