//
//  CoreNetworkRequestInterceptor.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import Foundation
import CoreNetworkInterface

final class CoreNetworkRequestInterceptor: RequestInterceptor {
    private let tokenStore: CoreTokenStorage?
    private let tokenRefresher: CoreNetworkTokenRefresher?
    private let defaultHeaders: [String: String]

    init(
        tokenStore: CoreTokenStorage?,
        tokenRefresher: CoreNetworkTokenRefresher?,
        defaultHeaders: [String: String]
    ) {
        self.tokenStore = tokenStore
        self.tokenRefresher = tokenRefresher
        self.defaultHeaders = defaultHeaders
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        Task {
            var request = urlRequest

            defaultHeaders.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }

            guard let accessToken = await tokenStore?.accessToken() else {
                completion(.failure(CoreNetworkClientError.missingAccessToken))
                return
            }

            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            completion(.success(request))
        }
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard
            request.retryCount == 0,
            request.response?.statusCode == 401,
            let tokenRefresher
        else {
            completion(.doNotRetry)
            return
        }

        Task {
            do {
                try await tokenRefresher.refresh()
                completion(.retry)
            } catch {
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
