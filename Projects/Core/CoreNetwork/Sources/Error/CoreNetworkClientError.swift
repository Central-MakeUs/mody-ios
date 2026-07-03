//
//  CoreNetworkClientError.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

enum CoreNetworkClientError: Error, Equatable {
    case invalidURL
    case missingAccessToken
    case refreshTokenMissing
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case tooManyRequests
    case internalServerError
    case badGateway
    case serverMaintenance
    case gatewayTimeout
    case refreshTokenFailed
    case encodingFailed
    case decodingFailed
    case emptyResponse
    case networkUnreachable
    case timeout
    case sslPinningFailed
    case sessionInvalidated
    case unknown
    case serverError(statusCode: Int, code: String?, message: String?)
}

extension CoreNetworkClientError {
    static func statusCode(_ statusCode: Int) -> CoreNetworkClientError {
        switch statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .tooManyRequests
        case 500:
            return .internalServerError
        case 502:
            return .badGateway
        case 503:
            return .serverMaintenance
        case 504:
            return .gatewayTimeout
        default:
            return .unknown
        }
    }
}
