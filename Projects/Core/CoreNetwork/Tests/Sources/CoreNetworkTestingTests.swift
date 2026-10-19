//  CoreNetworkTestingTests.swift
//  CoreNetworkTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkInterface
import CoreNetworkTesting
import Foundation
import XCTest

final class CoreNetworkTestingTests: XCTestCase {
    func testNetworkStubForwardsEndpointAndUsesInjectedDecoder() async throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stub: CoreNetworkProtocol = CoreNetworkStub(decoder: decoder) { endpoint in
            XCTAssertEqual(endpoint.path, "items")
            XCTAssertEqual(endpoint.method, .POST)
            XCTAssertEqual(endpoint.queryParameters, ["page": "2"])
            XCTAssertEqual(endpoint.headers, ["X-Demo": "preview"])
            XCTAssertEqual(endpoint.bodyParameters as? String, "payload")
            XCTAssertFalse(endpoint.requiresAuthorization)
            return Data(#"{"item_id":7}"#.utf8)
        }
        let item: Item = try await stub.request(CoreNetworkEndpoint(
            path: "items", method: .POST, headers: ["X-Demo": "preview"],
            queryParameters: ["page": "2"], bodyParameters: "payload", requiresAuthorization: false))
        XCTAssertEqual(item.itemId, 7)
    }

    func testNetworkStubPropagatesScenarioFailure() async {
        let stub = CoreNetworkStub { _ in throw URLError(.timedOut) }
        do {
            let _: Item = try await stub.request(CoreNetworkEndpoint(path: "items"))
            XCTFail("Expected scenario failure")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .timedOut)
        }
    }

    func testCancelledDelayedRequestDoesNotCallHandler() async {
        let stub = CoreNetworkStub(responseDelay: .seconds(60)) { _ in
            XCTFail("Cancelled request must not execute the scenario handler")
            return Data()
        }
        let request = Task {
            let item: Item = try await stub.request(CoreNetworkEndpoint(path: "items"))
            return item
        }
        request.cancel()
        do {
            _ = try await request.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }

    func testTokenStoragePreservesAndReplacesRefreshToken() async {
        let stub: CoreTokenStorage = CoreTokenStorageStub(accessToken: "old-access", refreshToken: "old-refresh")
        await stub.save(accessToken: "new-access", refreshToken: nil)
        let access = await stub.accessToken()
        let preservedRefresh = await stub.refreshToken()
        XCTAssertEqual(access, "new-access")
        XCTAssertEqual(preservedRefresh, "old-refresh")
        await stub.save(accessToken: "latest-access", refreshToken: "new-refresh")
        let replacedRefresh = await stub.refreshToken()
        XCTAssertEqual(replacedRefresh, "new-refresh")
    }

    private struct Item: Decodable { let itemId: Int }
}
