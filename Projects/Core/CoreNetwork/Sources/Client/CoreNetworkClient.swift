//
//  CoreNetworkClient.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import Foundation
import CoreNetworkInterface

public final class CoreNetworkClient: CoreNetworkProtocol {
    let baseURL: URL
    let session: Session
    let requestInterceptor: CoreNetworkRequestInterceptor
    let defaultHeaders: [String: String]
    let decoder: JSONDecoder

    public convenience init(
        tokenStore: CoreTokenStorage? = nil,
        refreshTokenEndpoint: CoreNetworkEndpoint? = nil,
        defaultHeaders: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.init(
            baseURL: CoreNetworkBaseURLProvider.current,
            session: Self.makeSession(),
            tokenStore: tokenStore,
            refreshTokenEndpoint: refreshTokenEndpoint,
            defaultHeaders: defaultHeaders,
            decoder: decoder
        )
    }

    init(
        baseURL: URL,
        session: Session,
        refreshSession: Session? = nil,
        tokenStore: CoreTokenStorage? = nil,
        refreshTokenEndpoint: CoreNetworkEndpoint? = nil,
        defaultHeaders: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.defaultHeaders = defaultHeaders
        self.decoder = decoder

        let tokenRefresher: CoreNetworkTokenRefresher?
        if let tokenStore, let refreshTokenEndpoint {
            tokenRefresher = CoreNetworkTokenRefresher(
                baseURL: baseURL,
                refreshTokenEndpoint: refreshTokenEndpoint,
                tokenStore: tokenStore,
                decoder: decoder,
                session: refreshSession
            )
        } else {
            tokenRefresher = nil
        }
        self.requestInterceptor = CoreNetworkRequestInterceptor(
            tokenStore: tokenStore,
            tokenRefresher: tokenRefresher,
            defaultHeaders: defaultHeaders
        )
    }

    public func request<Response: Decodable>(_ endpoint: CoreNetworkEndpoint) async throws -> Response {
        return try await call(endpoint)
    }
}

private extension CoreNetworkClient {
    static func makeSession() -> Session {
        Session(
            configuration: makeSessionConfiguration(),
            eventMonitors: [CoreNetworkEventMonitor()]
        )
    }

    static func makeSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 30
        return configuration
    }
}
