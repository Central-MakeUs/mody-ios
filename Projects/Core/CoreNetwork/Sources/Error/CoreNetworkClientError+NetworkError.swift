//
//  CoreNetworkClientError+NetworkError.swift
//  CoreNetwork
//
//  Created by 김동준 on 7/3/26
//

import CommonDomain

extension CoreNetworkClientError {
    var asNetworkError: NetworkError {
        switch self {
        case .badRequest:
            return .badRequest
        case .unauthorized,
             .missingAccessToken,
             .refreshTokenMissing,
             .refreshTokenFailed:
            return .unauthorized
        case .forbidden:
            return .forbidden
        case .notFound:
            return .notFound
        case .tooManyRequests:
            return .tooManyRequests
        case .internalServerError,
             .badGateway,
             .serverMaintenance,
             .gatewayTimeout:
            return .serverUnavailable
        case .networkUnreachable:
            return .networkUnavailable
        case .timeout:
            return .timeout
        case .encodingFailed,
             .decodingFailed,
             .emptyResponse:
            return .invalidResponse
        case let .serverError(_, code, message):
            return .serverError(code: code, message: message)
        default:
            return .unknown
        }
    }
}
