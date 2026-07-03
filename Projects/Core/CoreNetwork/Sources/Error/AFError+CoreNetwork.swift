//
//  AFError+CoreNetwork.swift
//  CoreNetwork
//
//  Created by 김동준 on 6/30/26
//

import Alamofire
import Foundation

extension AFError {
    func asCoreNetworkError() -> CoreNetworkClientError {
        switch self {
        case let .requestRetryFailed(retryError, originalError):
            if let coreNetworkError = retryError as? CoreNetworkClientError {
                return coreNetworkError
            }

            if let afError = retryError as? AFError {
                return afError.asCoreNetworkError()
            }

            if let afError = originalError as? AFError {
                return afError.asCoreNetworkError()
            }

            return .unknown

        case .invalidURL,
             .createURLRequestFailed,
             .urlRequestValidationFailed:
            return .invalidURL

        case .parameterEncodingFailed,
             .parameterEncoderFailed:
            return .encodingFailed

        case .requestAdaptationFailed:
            if let coreNetworkError = underlyingError as? CoreNetworkClientError {
                return coreNetworkError
            }

            return .unknown

        case let .responseValidationFailed(reason):
            switch reason {
            case .unacceptableStatusCode(let statusCode):
                return CoreNetworkClientError.statusCode(statusCode)
            default:
                return .unknown
            }

        case let .responseSerializationFailed(reason):
            switch reason {
            case .decodingFailed:
                return .decodingFailed
            case .inputDataNilOrZeroLength,
                 .invalidEmptyResponse:
                return .emptyResponse
            default:
                return .unknown
            }

        case .sessionTaskFailed(let error):
            guard let urlError = error as? URLError else {
                return .unknown
            }

            switch urlError.code {
            case .timedOut:
                return .timeout
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .cannotConnectToHost,
                 .cannotFindHost,
                 .dnsLookupFailed,
                 .internationalRoamingOff,
                 .dataNotAllowed:
                return .networkUnreachable
            default:
                return .unknown
            }

        case .explicitlyCancelled:
            return .unknown

        case .serverTrustEvaluationFailed:
            return .sslPinningFailed

        case .sessionInvalidated,
             .sessionDeinitialized:
            return .sessionInvalidated

        default:
            return .unknown
        }
    }
}
