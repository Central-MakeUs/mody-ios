//  CoreNetworkClientTests.swift
//  CoreNetworkTests
//
//  Created by 김동준 on 10/9/26.
//

import CommonDomain
import CoreNetworkInterface
import Foundation
import XCTest
@testable import CoreNetwork

final class CoreNetworkClientTests: XCTestCase {
    func testPublicRequestDecodesTypedResponseAndTransmitsEndpoint() async throws {
        let transport = CoreNetworkTransportSpy(json: #"{"isSuccess":true,"result":42}"#)
        let sut = makeClient(transport, headers: ["X-Client": "mody"])
        let response: CoreNetworkResponse<Int> = try await sut.request(CoreNetworkEndpoint(
            path: "items", method: .POST, bodyParameters: ["value": 7], requiresAuthorization: false))
        XCTAssertEqual(response.result, 42)
        let request = try XCTUnwrap(transport.requests.first)
        XCTAssertEqual(transport.requests.count, 1)
        XCTAssertEqual(request.url?.path, "/items")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Client"), "mody")
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(try JSONDecoder().decode([String: Int].self, from: CoreNetworkTransportSpy.body(of: request)), ["value": 7])
    }

    func testInjectedDecoderIsUsed() async throws {
        let transport = CoreNetworkTransportSpy(json: #"{"item_id":7}"#)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let sut = CoreNetworkClient(baseURL: transport.baseURL, session: transport.session, decoder: decoder)
        let response: Item = try await sut.request(publicEndpoint)
        XCTAssertEqual(response.itemId, 7)
    }

    func testEmpty200ResponseSupportsEmptyResponseContract() async throws {
        let transport = CoreNetworkTransportSpy(json: "")
        let response: CoreNetworkEmptyResponse = try await makeClient(transport).request(publicEndpoint)
        XCTAssertEqual(response, CoreNetworkEmptyResponse())
    }

    func testMalformedOrEmptyTypedResponseMapsToInvalidResponse() async {
        for json in ["not-json", ""] {
            let transport = CoreNetworkTransportSpy(json: json)
            await assertFailure(makeClient(transport), expected: .invalidResponse)
            XCTAssertEqual(transport.requests.count, 1)
        }
    }

    func testDecodingFailureWithDecodableEnvelopePreservesInvalidResponseFallback() async {
        let transport = CoreNetworkTransportSpy(json: #"{"itemId":"invalid"}"#)
        await assertFailure(makeClient(transport), expected: .serverError(code: nil, message: nil, fallback: .invalidResponse))
        XCTAssertEqual(transport.requests.count, 1)
    }

    func testStatusFailuresWithoutEnvelopeUseDomainFallback() async {
        for (status, expected) in [(400, NetworkError.badRequest), (401, .unauthorized),
                                  (403, .forbidden), (404, .notFound), (429, .tooManyRequests),
                                  (500, .serverUnavailable), (502, .serverUnavailable),
                                  (503, .serverUnavailable), (504, .serverUnavailable), (418, .unknown)] {
            let transport = CoreNetworkTransportSpy(status: status, json: "not-json")
            await assertFailure(makeClient(transport), expected: expected)
            XCTAssertEqual(transport.requests.count, 1)
        }
    }

    func testServerEnvelopePreservesCodeMessageAndFallback() async {
        let transport = CoreNetworkTransportSpy(status: 403, json: #"{"isSuccess":false,"code":"DENIED","message":"denied","result":null}"#)
        await assertFailure(makeClient(transport), expected: .serverError(code: "DENIED", message: "denied", fallback: .forbidden))
    }

    func testTransportFailuresMapToDomainErrors() async {
        for (code, expected) in [(URLError.timedOut, NetworkError.timeout), (.notConnectedToInternet, .networkUnavailable)] {
            let transport = CoreNetworkTransportSpy { _, _ in throw URLError(code) }
            await assertFailure(makeClient(transport), expected: expected)
        }
    }

    func testAuthorizedRequestUsesStoredAccessToken() async throws {
        let transport = CoreNetworkTransportSpy(json: #"{"itemId":7}"#)
        let storage = CoreTokenStorageSpy()
        let response: Item = try await makeClient(transport, storage: storage).request(CoreNetworkEndpoint(path: "items"))
        XCTAssertEqual(response.itemId, 7)
        XCTAssertEqual(transport.requests.first?.value(forHTTPHeaderField: "Authorization"), "Bearer old-access")
    }

    func testMissingAccessTokenFailsBeforeTransport() async {
        for storage in [nil, CoreTokenStorageSpy(access: nil)] as [CoreTokenStorageSpy?] {
            let transport = CoreNetworkTransportSpy()
            await assertFailure(makeClient(transport, storage: storage), endpoint: CoreNetworkEndpoint(path: "items"), expected: .unauthorized)
            XCTAssertTrue(transport.requests.isEmpty)
        }
    }

    func testPublicRequestDoesNotRequireTokensOrRefresh() async throws {
        let transport = CoreNetworkTransportSpy(json: #"{"itemId":7}"#)
        let storage = CoreTokenStorageSpy(access: nil, refresh: nil)
        let response: Item = try await makeClient(transport, storage: storage, refresh: true).request(publicEndpoint)
        XCTAssertEqual(response.itemId, 7)
        XCTAssertNil(transport.requests.first?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(transport.requests.count, 1)
        let saved = await storage.savedTokens
        XCTAssertTrue(saved.isEmpty)
    }

    func test401RefreshSavesTokensThenRetriesWithNewAccessToken() async throws {
        let transport = CoreNetworkTransportSpy { request, count in
            if request.url?.path == "/refresh" {
                XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
                XCTAssertEqual(try JSONDecoder().decode([String: String].self, from: CoreNetworkTransportSpy.body(of: request)), ["refreshToken": "old-refresh"])
                return (200, Data(#"{"result":{"accessToken":"new-access","refreshToken":"new-refresh"}}"#.utf8))
            }
            return count == 1 ? (401, Data()) : (200, Data(#"{"itemId":7}"#.utf8))
        }
        let storage = CoreTokenStorageSpy()
        let response: Item = try await makeClient(transport, storage: storage, refresh: true).request(CoreNetworkEndpoint(path: "items"))
        XCTAssertEqual(response.itemId, 7)
        XCTAssertEqual(transport.requests.map { $0.url!.path }, ["/items", "/refresh", "/items"])
        XCTAssertEqual(transport.requests.last?.value(forHTTPHeaderField: "Authorization"), "Bearer new-access")
        let saved = await storage.savedTokens
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.0, "new-access")
        XCTAssertEqual(saved.first?.1, "new-refresh")
    }

    func testSecond401StopsAfterOneRefresh() async {
        let transport = CoreNetworkTransportSpy { request, _ in
            if request.url?.path == "/refresh" { return (200, Data(#"{"result":{"accessToken":"new-access"}}"#.utf8)) }
            return (401, Data())
        }
        let storage = CoreTokenStorageSpy()
        await assertFailure(makeClient(transport, storage: storage, refresh: true), endpoint: CoreNetworkEndpoint(path: "items"), expected: .unauthorized)
        XCTAssertEqual(transport.requests.map { $0.url!.path }, ["/items", "/refresh", "/items"])
        let saved = await storage.savedTokens
        XCTAssertEqual(saved.count, 1)
        XCTAssertNil(saved.first?.1)
        let refresh = await storage.refreshToken()
        XCTAssertEqual(refresh, "old-refresh")
    }

    func test401WithoutRefresherDoesNotRetry() async {
        let transport = CoreNetworkTransportSpy(status: 401, json: "")
        await assertFailure(makeClient(transport, storage: CoreTokenStorageSpy()), endpoint: CoreNetworkEndpoint(path: "items"), expected: .unauthorized)
        XCTAssertEqual(transport.requests.count, 1)
    }

    func testMissingRefreshTokenDoesNotSendRefreshOrRetry() async {
        let transport = CoreNetworkTransportSpy(status: 401, json: "")
        let storage = CoreTokenStorageSpy(refresh: nil)
        await assertFailure(makeClient(transport, storage: storage, refresh: true), endpoint: CoreNetworkEndpoint(path: "items"), expected: .unauthorized)
        XCTAssertEqual(transport.requests.count, 1)
        let saved = await storage.savedTokens
        XCTAssertTrue(saved.isEmpty)
    }

    func testRefreshFailureDoesNotSaveOrRetry() async {
        for (status, json) in [(500, ""), (200, "not-json"), (200, "{}"), (200, #"{"result":null}"#)] {
            let transport = CoreNetworkTransportSpy { request, _ in
                request.url?.path == "/refresh" ? (status, Data(json.utf8)) : (401, Data())
            }
            let storage = CoreTokenStorageSpy()
            await assertFailure(makeClient(transport, storage: storage, refresh: true), endpoint: CoreNetworkEndpoint(path: "items"), expected: .unauthorized)
            XCTAssertEqual(transport.requests.map { $0.url!.path }, ["/items", "/refresh"])
            let saved = await storage.savedTokens
            XCTAssertTrue(saved.isEmpty)
        }
    }

    func testNon401DoesNotRefresh() async {
        let transport = CoreNetworkTransportSpy(status: 403, json: "")
        let storage = CoreTokenStorageSpy()
        await assertFailure(makeClient(transport, storage: storage, refresh: true), endpoint: CoreNetworkEndpoint(path: "items"), expected: .forbidden)
        XCTAssertEqual(transport.requests.count, 1)
        let saved = await storage.savedTokens
        XCTAssertTrue(saved.isEmpty)
    }

    func testFailureLogMasksSensitiveValuesAtEveryDepth() {
        let transport = CoreNetworkTransportSpy()
        let sut = makeClient(transport, headers: ["Authorization": "secret-auth", "X-Trace": "visible-trace"])
        let endpoint = CoreNetworkEndpoint(path: "items", queryParameters: ["accessToken": "secret-query"],
            bodyParameters: ["nested": [["password": "secret-password", "email": "secret-email", "value": "visible-value"]]])
        let log = sut.apiFailureLog(endpoint: endpoint, coreNetworkClientError: .timeout, networkError: .timeout)
        for value in ["secret-auth", "secret-query", "secret-password", "secret-email"] { XCTAssertFalse(log.contains(value)) }
        XCTAssertTrue(log.contains("visible-trace"))
        XCTAssertTrue(log.contains("visible-value"))
        XCTAssertTrue(log.contains("***"))
    }

    private var publicEndpoint: CoreNetworkEndpoint { CoreNetworkEndpoint(path: "items", requiresAuthorization: false) }

    private func makeClient(_ transport: CoreNetworkTransportSpy, storage: CoreTokenStorageSpy? = nil,
                            refresh: Bool = false, headers: [String: String] = [:]) -> CoreNetworkClient {
        CoreNetworkClient(baseURL: transport.baseURL, session: transport.session, refreshSession: transport.session,
                          tokenStore: storage, refreshTokenEndpoint: refresh ? CoreNetworkEndpoint(path: "refresh", method: .POST) : nil,
                          defaultHeaders: headers)
    }

    private func assertFailure(_ sut: CoreNetworkClient, endpoint: CoreNetworkEndpoint? = nil,
                               expected: NetworkError, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            let _: Item = try await sut.request(endpoint ?? publicEndpoint)
            XCTFail("Expected failure", file: file, line: line)
        } catch { XCTAssertEqual(error as? NetworkError, expected, file: file, line: line) }
    }

    private struct Item: Decodable { let itemId: Int }
}
