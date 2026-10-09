//  NotificationEndpointTests.swift
//  CoreNotificationTests
//
//  Created by 김동준 on 10/9/26.
//

import CoreNetworkTesting
import Foundation
import XCTest

@testable import CoreNotification

final class NotificationEndpointTests: XCTestCase {
    func testPushTokenEndpointAndEncodedBody() throws {
        let endpoint = NotificationEndpoint.postPushFCMToken(
            PushTokenRegisterRequest(deviceId: "device", fcmToken: "token")
        )

        XCTAssertEqual(endpoint.path, "api/v1/notifications/push-token")
        XCTAssertEqual(endpoint.method, .POST)
        XCTAssertTrue(endpoint.requiresAuthorization)
        XCTAssertTrue(endpoint.headers.isEmpty)
        XCTAssertTrue(endpoint.queryParameters.isEmpty)
        let body = try CoreNetworkJSONFixture.body(of: endpoint)
        XCTAssertEqual(body as NSDictionary, ["deviceId": "device", "platform": "IOS", "fcmToken": "token"] as NSDictionary)
    }

    func testMissingDeviceIDIsOmittedFromBody() throws {
        let request = PushTokenRegisterRequest(deviceId: nil, fcmToken: "token")
        let endpoint = NotificationEndpoint.postPushFCMToken(request)

        let body = try CoreNetworkJSONFixture.body(of: endpoint)

        XCTAssertEqual(body as NSDictionary, ["platform": "IOS", "fcmToken": "token"] as NSDictionary)
    }

    func testListWithoutCursor() {
        let endpoint = NotificationEndpoint.getNotifications(cursor: nil, size: 15, allRead: true)

        XCTAssertEqual(endpoint.path, "api/v1/notifications")
        XCTAssertEqual(endpoint.method, .GET)
        XCTAssertTrue(endpoint.requiresAuthorization)
        XCTAssertEqual(endpoint.queryParameters, ["size": "15", "allRead": "true"])
        XCTAssertNil(endpoint.bodyParameters)
    }

    func testListWithCursorAndAllReadFalse() {
        let endpoint = NotificationEndpoint.getNotifications(cursor: 0, size: 30, allRead: false)

        XCTAssertEqual(endpoint.queryParameters, ["cursor": "0", "size": "30", "allRead": "false"])
    }

    func testUnreadEndpoint() {
        let endpoint = NotificationEndpoint.getUnreadExists()

        XCTAssertEqual(endpoint.path, "api/v1/notifications/unread-exists")
        XCTAssertEqual(endpoint.method, .GET)
        XCTAssertTrue(endpoint.requiresAuthorization)
        XCTAssertTrue(endpoint.queryParameters.isEmpty)
        XCTAssertNil(endpoint.bodyParameters)
    }
}
