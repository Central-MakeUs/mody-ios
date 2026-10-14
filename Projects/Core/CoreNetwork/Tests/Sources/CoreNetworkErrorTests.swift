//  CoreNetworkErrorTests.swift
//  CoreNetworkTests
//
//  Created by 김동준 on 10/9/26.
//

import Alamofire
import CommonDomain
import Foundation
import XCTest
@testable import CoreNetwork

final class CoreNetworkErrorTests: XCTestCase {
    func testStatusCodesMapToClientAndDomainErrors() {
        let cases: [(Int, CoreNetworkClientError, NetworkError)] = [
            (400, .badRequest, .badRequest), (401, .unauthorized, .unauthorized),
            (403, .forbidden, .forbidden), (404, .notFound, .notFound),
            (429, .tooManyRequests, .tooManyRequests), (500, .internalServerError, .serverUnavailable),
            (502, .badGateway, .serverUnavailable), (503, .serverMaintenance, .serverUnavailable),
            (504, .gatewayTimeout, .serverUnavailable), (418, .unknown, .unknown)
        ]
        for (status, internalError, domainError) in cases {
            XCTAssertEqual(CoreNetworkClientError.statusCode(status), internalError)
            XCTAssertEqual(internalError.asNetworkError, domainError)
            XCTAssertEqual(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: status)).asCoreNetworkClientError(), internalError)
        }
    }

    func testAuthenticationAndSerializationErrors() {
        for error in [CoreNetworkClientError.missingAccessToken, .refreshTokenMissing, .refreshTokenFailed] {
            XCTAssertEqual(error.asNetworkError, .unauthorized)
        }
        for error in [CoreNetworkClientError.encodingFailed, .decodingFailed, .emptyResponse] {
            XCTAssertEqual(error.asNetworkError, .invalidResponse)
        }
        for error in [CoreNetworkClientError.invalidURL, .sslPinningFailed, .sessionInvalidated, .unknown] {
            XCTAssertEqual(error.asNetworkError, .unknown)
        }
    }

    func testURLErrorsAndUnknownTransportFailure() {
        for code in [URLError.notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost,
                     .cannotFindHost, .dnsLookupFailed, .internationalRoamingOff, .dataNotAllowed] {
            let error = AFError.sessionTaskFailed(error: URLError(code)).asCoreNetworkClientError()
            XCTAssertEqual(error, .networkUnreachable)
            XCTAssertEqual(error.asNetworkError, .networkUnavailable)
        }
        XCTAssertEqual(AFError.sessionTaskFailed(error: URLError(.timedOut)).asCoreNetworkClientError(), .timeout)
        XCTAssertEqual(AFError.sessionTaskFailed(error: URLError(.cancelled)).asCoreNetworkClientError(), .unknown)
        XCTAssertEqual(AFError.sessionTaskFailed(error: NSError(domain: "fixture", code: 1)).asCoreNetworkClientError(), .unknown)
    }

    func testAlamofireEncodingDecodingAndSessionFailures() {
        let cases: [(AFError, CoreNetworkClientError)] = [
            (.invalidURL(url: "invalid"), .invalidURL),
            (.createURLRequestFailed(error: URLError(.badURL)), .invalidURL),
            (.urlRequestValidationFailed(reason: .bodyDataInGETRequest(Data())), .invalidURL),
            (.parameterEncodingFailed(reason: .missingURL), .encodingFailed),
            (.parameterEncoderFailed(reason: .encoderFailed(error: URLError(.badURL))), .encodingFailed),
            (.responseSerializationFailed(reason: .decodingFailed(error: URLError(.cannotDecodeContentData))), .decodingFailed),
            (.responseSerializationFailed(reason: .inputDataNilOrZeroLength), .emptyResponse),
            (.responseSerializationFailed(reason: .invalidEmptyResponse(type: "Int")), .emptyResponse),
            (.responseSerializationFailed(reason: .inputFileNil), .unknown),
            (.responseValidationFailed(reason: .dataFileNil), .unknown),
            (.sessionInvalidated(error: nil), .sessionInvalidated), (.sessionDeinitialized, .sessionInvalidated),
            (.explicitlyCancelled, .unknown)
        ]
        for (afError, expected) in cases { XCTAssertEqual(afError.asCoreNetworkClientError(), expected) }
    }

    func testAdaptationAndNestedRetryFailuresPreserveAuthenticationError() {
        XCTAssertEqual(AFError.requestAdaptationFailed(error: CoreNetworkClientError.missingAccessToken).asCoreNetworkClientError(), .missingAccessToken)
        XCTAssertEqual(AFError.requestAdaptationFailed(error: URLError(.badURL)).asCoreNetworkClientError(), .unknown)
        let original = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401))
        XCTAssertEqual(AFError.requestRetryFailed(retryError: CoreNetworkClientError.refreshTokenMissing, originalError: original).asCoreNetworkClientError(), .refreshTokenMissing)
        XCTAssertEqual(AFError.requestRetryFailed(retryError: AFError.sessionTaskFailed(error: URLError(.timedOut)), originalError: original).asCoreNetworkClientError(), .timeout)
        XCTAssertEqual(AFError.requestRetryFailed(retryError: URLError(.badURL), originalError: original).asCoreNetworkClientError(), .unauthorized)
        XCTAssertEqual(AFError.requestRetryFailed(retryError: URLError(.badURL), originalError: URLError(.badURL)).asCoreNetworkClientError(), .unknown)
    }

    func testServerErrorPreservesCodeMessageAndFallback() {
        XCTAssertEqual(CoreNetworkClientError.serverError(statusCode: 403, code: "DENIED", message: "denied", fallback: .forbidden).asNetworkError,
                       .serverError(code: "DENIED", message: "denied", fallback: .forbidden))
    }
}
