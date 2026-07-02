//
//  CoreNetworkTokenRefresher.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import Foundation
import CoreNetworkInterface

final class CoreNetworkTokenRefresher {
    private let baseURL: URL
    private let refreshTokenEndpoint: CoreNetworkEndpoint
    private let tokenStore: CoreTokenStorage
    private let session: Session
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        refreshTokenEndpoint: CoreNetworkEndpoint,
        tokenStore: CoreTokenStorage,
        decoder: JSONDecoder
    ) {
        self.baseURL = baseURL
        self.refreshTokenEndpoint = refreshTokenEndpoint
        self.tokenStore = tokenStore
        self.session = Session(eventMonitors: [CoreNetworkEventMonitor()])
        self.decoder = decoder
    }

    func refresh() async throws {
        let refreshToken = try await currentRefreshToken()
        let endpoint = makeRefreshEndpoint(refreshToken: refreshToken)
        let response = try await requestRefreshToken(endpoint: endpoint)

        await save(response)
    }
}

private extension CoreNetworkTokenRefresher {
    func currentRefreshToken() async throws -> String {
        guard let refreshToken = await tokenStore.refreshToken() else {
            throw CoreNetworkClientError.refreshTokenMissing
        }

        return refreshToken
    }

    func makeRefreshEndpoint(refreshToken: String) -> CoreNetworkEndpoint {
        CoreNetworkEndpoint(
            path: refreshTokenEndpoint.path,
            method: refreshTokenEndpoint.method,
            headers: refreshTokenEndpoint.headers,
            queryParameters: refreshTokenEndpoint.queryParameters,
            bodyParameters: makeBodyParameters(refreshToken: refreshToken),
            requiresAuthorization: false
        )
    }

    func makeBodyParameters(refreshToken: String) -> [String: String] {
        var bodyParameters = refreshTokenEndpoint.bodyParameters
        bodyParameters["refreshToken"] = refreshToken
        return bodyParameters
    }

    func requestRefreshToken(endpoint: CoreNetworkEndpoint) async throws -> AuthRefreshTokenResponseDTO {
        let response = await session
            .request(
                CoreNetworkRequest(
                    baseURL: baseURL,
                    endpoint: endpoint,
                    defaultHeaders: [:]
                )
            )
            .validate(statusCode: 200..<300)
            .serializingDecodable(
                CoreNetworkResponse<AuthRefreshTokenResponseDTO>.self,
                decoder: decoder
            )
            .response

        switch response.result {
        case .success(let response):
            guard let token = response.result else {
                throw CoreNetworkClientError.refreshTokenFailed
            }

            return token
        case .failure:
            throw CoreNetworkClientError.refreshTokenFailed
        }
    }

    func save(_ response: AuthRefreshTokenResponseDTO) async {
        guard let accessToken = response.accessToken else { return }

        await tokenStore.save(
            accessToken: accessToken,
            refreshToken: response.refreshToken
        )
    }
}

// TODO: Remove later
private struct AuthRefreshTokenResponseDTO: Decodable {
    let accessToken: String?
    let refreshToken: String?
}
