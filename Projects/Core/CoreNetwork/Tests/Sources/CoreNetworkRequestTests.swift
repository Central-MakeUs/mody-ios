//  CoreNetworkRequestTests.swift
//  CoreNetworkTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkInterface
import Foundation
import XCTest
@testable import CoreNetwork

final class CoreNetworkRequestTests: XCTestCase {
    private let baseURL = URL(string: "https://example.test/base")!

    func testEveryHTTPMethodAndPath() throws {
        for method in [HttpMethod.GET, .POST, .PUT, .PATCH, .DELETE, .HEAD] {
            let request = try makeRequest(CoreNetworkEndpoint(path: "api/v1/items", method: method))
            XCTAssertEqual(request.url?.path, "/base/api/v1/items")
            XCTAssertEqual(request.httpMethod, method.rawValue)
            XCTAssertNil(request.httpBody)
        }
    }

    func testQueryPreservesSpecialCharactersAndUnicode() throws {
        let query = ["search": "모디 & a+b/?", "empty": ""]
        let request = try makeRequest(CoreNetworkEndpoint(path: "items", queryParameters: query))
        let items = try XCTUnwrap(URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems)
        XCTAssertEqual(Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") }), query)
    }

    func testEndpointHeadersOverrideDefaultsCaseInsensitively() throws {
        let request = try makeRequest(CoreNetworkEndpoint(path: "items", headers: ["x-mode": "endpoint", "content-type": "custom"]),
                                      defaults: ["X-Mode": "default", "Content-Type": "default", "X-Keep": "keep"])
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Mode"), "endpoint")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "custom")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Keep"), "keep")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept-Charset"), "UTF-8")
    }

    func testDefaultHeadersAndEncodedJSONBody() throws {
        let request = try makeRequest(CoreNetworkEndpoint(path: "items", method: .POST, bodyParameters: ["nickname": "모디"]))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")
        XCTAssertEqual(try JSONDecoder().decode([String: String].self, from: XCTUnwrap(request.httpBody)), ["nickname": "모디"])
    }

    func testBodyEncodingFailureIsNormalized() {
        XCTAssertThrowsError(try makeRequest(CoreNetworkEndpoint(path: "items", bodyParameters: FailingBody()))) {
            XCTAssertEqual($0 as? CoreNetworkClientError, .encodingFailed)
        }
    }

    func testEndpointDefaultsAndResponseEnvelope() throws {
        let endpoint = CoreNetworkEndpoint(path: "items")
        XCTAssertTrue(endpoint.requiresAuthorization)
        XCTAssertEqual(endpoint.method, .GET)
        XCTAssertTrue(endpoint.headers.isEmpty)
        XCTAssertTrue(endpoint.queryParameters.isEmpty)
        XCTAssertNil(endpoint.bodyParameters)
        let response = try JSONDecoder().decode(CoreNetworkResponse<Int>.self,
            from: Data(#"{"isSuccess":true,"code":"OK","message":"done","result":42}"#.utf8))
        XCTAssertEqual(response.isSuccess, true)
        XCTAssertEqual(response.code, "OK")
        XCTAssertEqual(response.message, "done")
        XCTAssertEqual(response.result, 42)
        let empty = try JSONDecoder().decode(CoreNetworkResponse<Int>.self, from: Data("{}".utf8))
        XCTAssertNil(empty.result)
    }

    private func makeRequest(_ endpoint: CoreNetworkEndpoint, defaults: [String: String] = [:]) throws -> URLRequest {
        try CoreNetworkRequest(baseURL: baseURL, endpoint: endpoint, defaultHeaders: defaults).asURLRequest()
    }

    private struct FailingBody: Encodable {
        func encode(to encoder: Encoder) throws { throw EncodingError.invalidValue("", .init(codingPath: [], debugDescription: "fixture")) }
    }
}
