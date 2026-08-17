//
//  CoreNetworkClient+ErrorHandling.swift
//  CoreNetwork
//
//  Created by 김동준 on 7/3/26
//

import Alamofire
import CoreNetworkInterface
import ModyLogger

extension CoreNetworkClient {
    func execute<Response>(
        endpoint: CoreNetworkEndpoint,
        operation: () async throws -> Response
    ) async throws -> Response {
        do {
            return try await operation()
        } catch {
            try handleFailure(error, endpoint: endpoint)
        }
    }

    func handleFailure(
        _ error: Error,
        endpoint: CoreNetworkEndpoint
    ) throws -> Never {
        let coreNetworkClientError = toCoreNetworkClientError(error)
        let networkError = coreNetworkClientError.asNetworkError

        ModyLogger.error(apiFailureLog(
            endpoint: endpoint,
            coreNetworkClientError: coreNetworkClientError,
            networkError: networkError
        ))
        analyticsUseCase.log(apiFailureEvent(
            endpoint: endpoint,
            networkError: networkError
        ))

        throw networkError
    }

    func toCoreNetworkClientError(_ error: Error) -> CoreNetworkClientError {
        if let coreNetworkClientError = error as? CoreNetworkClientError {
            return coreNetworkClientError
        }

        if let afError = error as? AFError {
            return afError.asCoreNetworkClientError()
        }
        
        return .unknown
    }
}
