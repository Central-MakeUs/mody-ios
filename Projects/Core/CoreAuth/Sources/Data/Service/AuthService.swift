//
//  AuthService.swift
//  CoreAuth
//
//  Created by 김동준 on 7/2/26
//

import CommonDomain
import CoreAuthInterface
import CoreNetworkInterface

public struct AuthService {
    private let network: CoreNetworkProtocol

    public init(network: CoreNetworkProtocol) {
        self.network = network
    }

    func getSignIn(
        loginType: SocialLoginType,
        accessToken: String
    ) async throws -> SocialLoginResponse {
        let endpoint = AuthEndpoint.getSignIn(
            loginType: loginType,
            accessToken: accessToken
        )
        
        let response: CoreNetworkResponse<SocialLoginResponse> = try await network.request(
            endpoint
        )

        guard let result = response.result else {
            // TODO: EmptyResponseError
            throw AuthError.unknown
        }

        return result
    }
}
