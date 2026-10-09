//  NotificationServiceTests.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkTesting
import XCTest

@testable import CoreNotification

final class NotificationServiceTests: XCTestCase {
    func testPushAcceptsEmptyResultAndSendsEncodedRequest() async throws {
        let network = NotificationNetworkSpy()
        network.response = try CoreNetworkJSONFixture.response()
        let sut = NotificationService(network: network)

        try await sut.postPushFCMToken(PushTokenRegisterRequest(deviceId: "device", fcmToken: "token"))

        XCTAssertEqual(network.endpoints.count, 1)
        let endpoint = try XCTUnwrap(network.endpoints.first)
        XCTAssertEqual(endpoint.path, "api/v1/notifications/push-token")
        XCTAssertEqual(endpoint.method, .POST)
        let body = try CoreNetworkJSONFixture.body(of: endpoint)
        XCTAssertEqual(body["fcmToken"] as? String, "token")
        XCTAssertEqual(body["deviceId"] as? String, "device")
        XCTAssertEqual(body["platform"] as? String, "IOS")
    }

    func testListDecodesResultAndForwardsQuery() async throws {
        let network = NotificationNetworkSpy()
        network.response = try CoreNetworkJSONFixture.response(result: NotificationTestFixture.list)
        let sut = NotificationService(network: network)

        let response = try await sut.getNotifications(cursor: 50, size: 20, allRead: false)

        XCTAssertEqual(response.toDomain(), NotificationTestFixture.page)
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(network.endpoints.first?.queryParameters, ["cursor": "50", "size": "20", "allRead": "false"])
    }

    func testUnreadDecodesResult() async throws {
        let network = NotificationNetworkSpy()
        network.response = try CoreNetworkJSONFixture.response(result: ["hasUnread": true])
        let sut = NotificationService(network: network)

        let response = try await sut.getUnreadExists()

        XCTAssertTrue(response.toDomain())
        XCTAssertEqual(network.endpoints.count, 1)
        XCTAssertEqual(network.endpoints.first?.path, "api/v1/notifications/unread-exists")
    }

    func testListAndUnreadRejectMissingOrNullResult() async throws {
        for json in [#"{"isSuccess":true}"#, #"{"isSuccess":true,"result":null}"#] {
            let network = NotificationNetworkSpy()
            network.response = Data(json.utf8)
            let sut = NotificationService(network: network)

            await XCTAssertThrowsErrorAsync({ try await sut.getNotifications(cursor: nil, size: 15, allRead: true) }) {
                XCTAssertEqual(String(describing: $0), "emptyResponse")
            }
            await XCTAssertThrowsErrorAsync({ try await sut.getUnreadExists() }) {
                XCTAssertEqual(String(describing: $0), "emptyResponse")
            }
            XCTAssertEqual(network.endpoints.count, 2)
        }
    }

    func testAllRequestsPropagateNetworkErrorsAndCancellation() async {
        for error: Error in [NotificationTestError.expected, CancellationError()] {
            let network = NotificationNetworkSpy()
            network.error = error
            let sut = NotificationService(network: network)

            await XCTAssertThrowsErrorAsync({ try await sut.postPushFCMToken(PushTokenRegisterRequest(deviceId: nil, fcmToken: "token")) }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            await XCTAssertThrowsErrorAsync({ try await sut.getNotifications(cursor: nil, size: 15, allRead: true) }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            await XCTAssertThrowsErrorAsync({ try await sut.getUnreadExists() }) {
                XCTAssertEqual($0 as NSError, error as NSError)
            }
            XCTAssertEqual(network.endpoints.count, 3)
        }
    }

    func testMalformedResultPropagatesDecodingError() async {
        let network = NotificationNetworkSpy()
        network.response = Data(#"{"isSuccess":true,"result":{"notifications":"invalid"}}"#.utf8)
        let sut = NotificationService(network: network)

        await XCTAssertThrowsErrorAsync({ try await sut.getNotifications(cursor: nil, size: 15, allRead: true) }) {
            XCTAssertTrue($0 is DecodingError)
        }
    }
}
